# frozen_string_literal: true

# == Schema Information
#
# Table name: sub_investments
#
#  id                        :integer          not null, primary key
#  amount                    :decimal(12, 2)
#  archive_date              :date
#  creation_date             :date
#  currency                  :string(255)
#  current_accrued_amount    :decimal(, )
#  current_retained_amount   :decimal(, )
#  description               :text
#  exchange_rate             :decimal(, )
#  initial_description       :text
#  is_notify_investor        :boolean
#  memo                      :string(120)
#  months                    :integer
#  name                      :string           default("")
#  ori_amount                :decimal(12, 2)
#  private_note              :text
#  referrand_amount          :float
#  referrand_one_time_amount :decimal(12, 2)
#  referrand_one_time_date   :date
#  referrand_percent         :float
#  referrand_scheduled       :string(255)
#  remote_agreement_url      :string
#  scheduled                 :string(255)
#  signed_agreement_url      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  account_id                :integer
#  admin_user_id             :integer
#  envelope_id               :string
#  investment_id             :integer
#  investment_status_id      :integer
#  referrand_user_id         :integer
#  sub_investment_kind_id    :string
#  sub_investment_source_id  :string
#  transfer_from_id          :integer
#
# Indexes
#
#  index_sub_investments_on_account_id            (account_id)
#  index_sub_investments_on_admin_user_id         (admin_user_id)
#  index_sub_investments_on_investment_id         (investment_id)
#  index_sub_investments_on_investment_status_id  (investment_status_id)
#  index_sub_investments_on_transfer_from_id      (transfer_from_id)
#

# rubocop:disable Metrics/AbcSize
# rubocop:disable Security/Open
# rubocop:disable Metrics/ParameterLists
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
class SubInvestment < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ReferrandPayment
  include TargetEmail

  # icic include investments except imor
  scope :icic, -> { joins(:investment).where.not(investments: { investment_source_id: InvestmentSource.imor.id }) }
  scope :imor, -> { joins(:investment).where(investments: { investment_source_id: InvestmentSource.imor.id }) }

  scope :archived, -> { where('sub_investments.amount = 0') }
  scope :active, -> { where('sub_investments.amount != 0') }

  scope :order_name, lambda {
                       joins(:admin_user, :investment).order('admin_users.last_name asc, admin_users.first_name asc, investments.name asc')
                     }

  scope :cad, -> { where(currency: 'CAD') }
  scope :usd, -> { where(currency: 'USD') }

  belongs_to :admin_user
  belongs_to :investment
  belongs_to :account, optional: true # can be nil, only for imor sub investment
  belongs_to :investment_status

  belongs_to :transfer_from, class_name: 'SubInvestment', optional: true
  delegate :investment_source, to: :investment

  has_one :transferred_to, class_name: 'SubInvestment', foreign_key: 'transfer_from_id', dependent: :destroy, inverse_of: :transfer_from
  has_one_attached :signed_agreement
  has_one_attached :remote_agreement

  has_many :payments, dependent: :destroy
  has_many :withdraws, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :interest_periods, -> { order 'interest_periods.effect_date asc' }, dependent: :destroy, inverse_of: :sub_investment
  has_many :tasks, dependent: :destroy
  has_many :sub_distributions, dependent: :destroy

  accepts_nested_attributes_for :interest_periods, allow_destroy: true

  # mount_uploader :agreement, AgreementUploader

  validates :months, numericality: { less_than_or_equal_to: 360, greater_than: 0 }, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, presence: true # amount can be 0 because withdraw
  validates :valid_name?, presence: true # TODO: is this useful?
  validate :max_transfer_amount
  validate :require_account
  validate :exchange_rate_required

  after_initialize :set_default_attributes
  after_initialize :set_interest_period
  after_initialize :set_default_status
  before_save :clear_account
  before_save :set_name
  before_save :set_investment_kind_and_source
  before_save :update_payment_source_flag, if: :investment_id_changed?
  before_save :update_status, if: :amount_changed?
  before_save :log_events
  before_create :set_ori_amount
  after_create :handle_transfer
  after_create :build_agreement
  after_commit :adjust_investment_amount

  default_scope { order('sub_investments.name asc') }

  attr_accessor :balance, :paid_date, :due_date

  class << self
    def page_select
      results = []
      SubInvestment.joins(:admin_user).joins(:investment).order('admin_users.last_name asc, admin_users.first_name asc, investments.name, sub_investments.amount').each do |sub_investment|
        results << [
          "#{sub_investment.admin_user.name}-#{sub_investment.investment.name} #{sub_investment.amount_money}", sub_investment.id
        ]
      end
      results
    end
  end

  def valid_name?
    if admin_user.present?
      "#{admin_user.name}-#{investment&.name}-#{currency}"
    else
      'x'
    end
  end

  def monthly?
    scheduled.include? 'Month'
  end

  def quarterly?
    scheduled.include? 'Quarter'
  end

  def annually?
    scheduled.include? 'Annual'
  end

  def charge_fee(amount, due_date, email_subinvestor)
    AdminUser.find_by(email: 'kvh@innovationcic.com')
    target_investment = Investment.first_or_create(name: 'Innovation Capital Fee')

    withdraw = Withdraw.new({
      admin_user: admin_user,
      sub_investment: self,
      amount: amount,
      due_date: due_date,
      is_transfer: false,
      check_no: investment.fee_type,
    })
    withdraw.save

    fee = Fee.new({ investment: target_investment, sub_investment: self, amount: amount,
                    description: investment.fee_type, withdraw: withdraw })

    fee.save

    return unless email_subinvestor == 'true'

    FeesMailer.create(fee).deliver
  end

  def pay(date, amount, memo, to = admin_user_id)
    return if amount.zero?

    kind = Payment::Type_Interest
    kind = Payment::Type_AMF if memo.include? 'refer'
    kind = Payment::Type_Principal if memo.include? 'Principal'
    kind = Payment::Type_Withdraw if memo.include? 'Withdraw'
    kind = Payment::Type_Accrued if memo.include? 'Accrued'
    kind = Payment::Type_Retained if memo.include? 'Retained'
    common_pay date, amount, kind, memo, to
  end

  # TODO: this method can be removed?
  def pay_with_kind(date, amount, kind, memo, to = admin_user_id)
    common_pay date, amount, kind, memo, to
  end

  def customer_paid_payments
    payments.where(admin_user_id: admin_user_id, paid: true).order(:due_date)
  end

  def referrand_paid_payments
    payments.where(admin_user_id: referrand_user_id, paid: true)
  end

  def without_referrand?
    payments.where(admin_user_id: referrand_user_id).count.zero? # also :payment_kind => Payment::Type_AMF
  end

  def sum_of_payments(start_date = nil, end_date = nil, payment_type = '', paid: false)
    range_start_date = start_date && start_date > self.start_date ? start_date : self.start_date
    range_end_date = end_date || Time.zone.today
    payment_kind = ''
    final_amount = 0

    case payment_type
    when 'Accrued'
      payment_kind = Payment::Type_Accrued
    when 'Retained'
      payment_kind = Payment::Type_Retained
    when 'Misc'
      payment_kind = Payment::Type_Misc_Interest
    end

    if paid
      paid_payments = payments.select do |x|
        (x.payment_kind == payment_kind) && x.paid && x.paid_date >= range_start_date && x.paid_date <= range_end_date
      end
      final_amount = (paid_payments.sum(&:amount) || 0)
    else
      pending_payments = payments.select do |x|
        (x.payment_kind == payment_kind) && x.paid == false && x.due_date >= range_start_date && x.due_date <= range_end_date
      end
      final_amount = (pending_payments.sum(&:amount) || 0)
    end

    final_amount
  end

  def current_accrued(start_date = nil, end_date = nil, paid: false)
    @current_accrued ||= current_accrued_common(start_date, end_date, paid: paid)
  end

  def current_accrued_subinvest_currency(end_date = nil)
    @current_accrued_subinvest_currency ||= current_accrued_common(nil, end_date)
  end

  def current_accrued_steps
    accrued_current.final_steps
  end

  def current_retained(start_date = nil, end_date = nil, paid: false)
    @current_retained ||= current_retained_common(start_date, end_date, paid: paid)
  end

  def current_retained_subinvest_currency(end_date = nil)
    @current_retained_subinvest_currency ||= current_retained_common(nil, end_date)
  end

  def current_retained_steps
    retained_current.final_steps
  end

  def current_misc(start_date = nil, end_date = nil, paid: false)
    @current_misc ||= current_misc_common(start_date, end_date, paid: paid)
  end

  def current_misc_subinvest_currency
    @current_misc_subinvest_currency ||= current_misc_common
  end

  def current_misc_steps
    retained_current.final_steps
  end

  # status for display
  def status
    investment_status.try(:name)
  end

  def per_annum
    return interest_periods.first.per_annum if interest_periods.length == 1

    interest_periods.sort { |x, y| y.effect_date <=> x.effect_date }.each do |ip|
      return ip.per_annum if ip.effect_date <= Time.zone.today
    end

    # if there is no interest period before today, use the first interest period
    interest_periods.first&.per_annum
  end

  def accrued_per_annum
    interest_periods.sort { |x, y| y.effect_date <=> x.effect_date }.each do |ip|
      return ip.accrued_per_annum || 0 if ip.effect_date <= Time.zone.today
    end
    # if there is no interest period before today, use the first interest period
    interest_periods.first&.accrued_per_annum || 0
  end

  def retained_per_annum
    interest_periods.sort { |x, y| y.effect_date <=> x.effect_date }.each do |ip|
      return ip.retained_per_annum || 0 if ip.effect_date <= Time.zone.today
    end
    # if there is no interest period before today, use the first interest period
    interest_periods.first&.retained_per_annum || 0
  end

  def start_date
    @first_interest_period ||= interest_periods.min_by(&:effect_date)

    @first_interest_period.effect_date
  end

  def end_date
    @end_date ||= (start_date + months.months)
  end

  def months_passed
    date1 = start_date
    date2 = Time.zone.today
    ((date2.year * 12) + date2.month) - ((date1.year * 12) + date1.month)
  end

  def build_agreement
    file_name = BuildAgreementService.new.call(self)
    file = open(file_name)
    remote_agreement.purge
    remote_agreement.attach(io: file, filename: file_name)

    FileUtils.rm_f(file_name)
  end

  def upload_signed_agreement(file)
    filename = "#{id}-#{name.parameterize}-agreement-signed.pdf"
    signed_agreement.purge
    signed_agreement.attach(io: file, filename: filename)
  end

  def transfer_to(sub_investment_id, amount, date, check_no = '')
    return false if date > end_date # can not transfer after end date

    inc_amount = amount
    transfer_to = SubInvestment.find(sub_investment_id)
    if currency == 'CAD' && transfer_to.currency == 'USD'
      inc_amount = amount * Investment.latest_rate('CAD')
    elsif currency == 'USD' && transfer_to.currency == 'CAD'
      inc_amount = amount / Investment.latest_rate('CAD')
    end

    # target sub-investment
    transfer_to = admin_user.sub_investments.find(sub_investment_id)
    Increase.create!(amount: inc_amount, admin_user_id: admin_user_id, due_date: date,
                     sub_investment_id: transfer_to.id, is_transfer: true, transfer_from: self, paid_date: Time.zone.today, check_no: check_no)
    # transfer payment
    # todo the transfer out payment should be paid automatically? also for transfer to new sub-investment
    withdraws.create!(amount: amount, admin_user_id: admin_user_id, due_date: date, is_transfer: true,
                      transfer_to: transfer_to, paid_date: Time.zone.today, check_no: check_no)
    UpdateSubInvestmentStatsService.new.call(sub_investment_id)
    UpdateSubInvestmentStatsWorker.perform_async(id)
  end

  def log_event(description, date = Time.zone.today)
    events.create(date: date, description: description)
  end

  # ownership_amount
  def ownership_amount
    @ownership_amount ||= (currency == investment.currency ? current_amount : current_amount * (exchange_rate || 1))
  end

  def cad_amount
    @cad_amount ||= if currency == 'CAD'
                      amount
                    else
                      amount * ExchangeRate.now_usd_to_cad_rate
                    end
  end

  # ownership_amount
  def ownership_ori_amount
    @ownership_ori_amount ||= (currency == investment.currency ? ori_amount : ori_amount * (exchange_rate || 1))
  end

  # different currency with investment?
  def different_currency?
    @different_currency ||= (currency != investment.currency)
  end

  def payments_with_no_paid_date
    payments.select { |x| x.paid && x.paid_date.nil? }
  end

  class Obj
    def initialize(date, action, amount_in, amount_out, balance, withdraw = nil, sub_investment = nil)
      @date = date
      @action = action
      @in = amount_in
      @out = amount_out
      @balance = balance
      @withdraw = withdraw
      @sub_investment = sub_investment
    end

    def to_key
      nil
    end

    def due_date
      date
    end

    attr_accessor :date, :action, :in, :out, :balance, :withdraw, :sub_investment
  end

  # amount steps
  def current_amount_steps(up_to_date = nil)
    current_amount = 0
    @current_amount_steps ||= begin
      steps = []
      if up_to_date.blank? || DateTime.parse(up_to_date) > start_date
        steps << if transfer_from
                   Obj.new(start_date,
                           "#{initial_description.presence || 'Initial amount'} - Transferred from #{transfer_from.name}", ori_amount, nil, ori_amount)
                 else
                   Obj.new(start_date, (initial_description.presence || 'Initial amount').to_s,
                           ori_amount, nil, ori_amount)
                 end

        current_amount = ori_amount
      end

      # steps << Obj.new(principal_payment.due_date, action, nil, withdraw.amount, current_amount)

      temp_steps = begin
        if up_to_date.present?
          withdraws.where('due_date <= ?', DateTime.parse(up_to_date)).to_a
        else
          withdraws.to_a
        end
      rescue
        withdraws.to_a
      end

      temp_steps << Obj.new(principal_payment.paid_date, 'Principal Paid', nil, principal_payment.amount, nil) if principal_paid? && principal_payment.paid_date && (up_to_date.blank? || DateTime.parse(up_to_date) > principal_payment.paid_date)

      temp_steps.sort_by { |e| e.due_date || Date.new(0o000) }.each do |withdraw|
        if withdraw.instance_of?(Increase)
          action = if withdraw.is_transfer
                     'Transfer in'
                   else
                     'Increase'
                   end
          current_amount -= withdraw.real_amount
          steps << Obj.new(withdraw.due_date, action, withdraw.amount, nil, current_amount)
        elsif withdraw.instance_of?(Withdraw) || withdraw.instance_of?(ReturnCapitalInvestor)
          action = if withdraw.is_transfer
                     'Transfer out'
                   else
                     'Withdraw'
                   end
          # puts "=======#{withdraw.id}"
          if (payment = Payment.payment_for_withdraw(withdraw))&.paid
            current_amount -= withdraw.real_amount
            steps << Obj.new(payment.paid_date, action, nil, withdraw.amount, current_amount)
          end
        else # principal payment, Obj
          current_amount -= withdraw.out
          steps << Obj.new(withdraw.date, withdraw.action, withdraw.in, withdraw.out, current_amount)
        end
      end
      # return
      steps
    end
  end

  # amount steps with transactions, need refactor :(
  def current_amount_steps_with_transaction(up_to_date = nil)
    current_amount = 0
    @current_amount_steps_with_transaction ||= begin
      steps = []
      if up_to_date.blank? || DateTime.parse(up_to_date) > start_date
        steps << if transfer_from
                   title = "#{initial_description.presence || 'Initial amount'} - Transferred from #{transfer_from.name}"
                   Obj.new(start_date, title, ori_amount, nil, ori_amount, nil, self)
                 else
                   Obj.new(start_date, (initial_description.presence || 'Initial amount').to_s, ori_amount, nil, ori_amount, nil, self)
                 end

        current_amount = ori_amount
      end

      temp_steps = begin
        if up_to_date.present?
          withdraws.where('due_date <= ?', DateTime.parse(up_to_date)).to_a
        else
          withdraws.to_a
        end
      rescue
        withdraws.to_a
      end

      temp_steps << Obj.new(principal_payment.paid_date, 'Principal Paid', nil, principal_payment.amount, nil, nil, self) if principal_paid? && principal_payment.paid_date && (up_to_date.blank? || DateTime.parse(up_to_date) > principal_payment.paid_date)

      temp_steps.sort_by { |e| e.due_date || Date.new(0o000) }.each do |withdraw|
        if withdraw.instance_of?(Increase)
          action = if withdraw.is_transfer
                     'Transfer in'
                   else
                     'Increase'
                   end
          current_amount -= withdraw.real_amount
          steps << Obj.new(withdraw.due_date, action, withdraw.amount, nil, current_amount, withdraw, self)
        elsif withdraw.instance_of?(Withdraw) || withdraw.instance_of?(ReturnCapitalInvestor)
          action = if withdraw.is_transfer
                     'Transfer out'
                   else
                     'Withdraw'
                   end
          # puts "=======#{withdraw.id}"
          if (payment = Payment.payment_for_withdraw(withdraw))&.paid
            current_amount -= withdraw.real_amount
            steps << Obj.new(payment.paid_date, action, nil, withdraw.amount, current_amount, withdraw, self)
          end
        else # principal payment, Obj
          current_amount -= withdraw.out
          steps << Obj.new(withdraw.date, withdraw.action, withdraw.in, withdraw.out, current_amount,
                           withdraw.withdraw, self)
        end
      end
      # return
      steps
    end
  end

  def affect_investment(affect_amount)
    new_amount    = amount - affect_amount
    sql           = "update sub_investments set amount = #{new_amount} where id=#{id}"
    sanitized_sql = ActionController::Base.helpers.sanitize(sql)
    SubInvestment.connection.execute(sanitized_sql)
  end

  def amount_money
    "#{number_to_currency(amount, { precision: 2 })} #{currency}"
  end

  # use ownership_amount
  def accrued_by_date(date)
    # find the first interest_period which has the accrued value not equal 0
    ip = interest_periods.where('accrued_per_annum != 0').first
    return 0 unless ip
    return 0 if date < ip.effect_date

    accrued_value = 0
    payments.where('payment_kind = ? and paid = ?', Payment::Type_Accrued, false).find_each do |p|
      accrued_value += p.try(:ownership_amount) * [(date - start_date).to_f / (p.due_date - start_date), 1].min
    end
    accrued_value
  end

  def retained_by_date(date)
    # find the first interest_period which has the retained value not equal 0
    ip = interest_periods.where('retained_per_annum != 0').first
    return 0 unless ip
    return 0 if date < ip.effect_date

    retained_value = 0
    payments.where('payment_kind = ? and paid = ?', Payment::Type_Retained, false).find_each do |p|
      retained_value += p.try(:ownership_amount) * [(date - start_date).to_f / (p.due_date - start_date), 1].min
    end
    retained_value
  end

  delegate :imor?, to: :investment

  def last_paid_date
    payment = payments.where(paid: true).order('due_date desc').first
    return payment.paid_date if payment&.paid_date

    payment&.due_date
  end

  def last_paid_payment_due_date
    payment = payments.where(paid: true).order('due_date desc').first
    return payment.due_date if payment&.paid_date

    payment&.due_date
  end

  def last_paid_type
    payment = payments.where(paid: true).order('due_date desc').first
    payment&.payment_kind
  end

  delegate :ici_usa?, to: :investment

  def usd_investment?
    investment.currency == 'USD'
  end

  def interest
    interest = interest_periods.first.per_annum

    interest_periods.each do |interest_period|
      break if interest_period.effect_date > Time.zone.today

      interest = interest_period.per_annum
    end

    interest
  end

  def accrued
    interest = interest_periods.first.accrued_per_annum

    interest_periods.each do |interest_period|
      break if interest_period.effect_date > Time.zone.today

      interest = interest_period.accrued_per_annum
    end

    interest
  end

  def retained
    interest = interest_periods.first.retained_per_annum

    interest_periods.each do |interest_period|
      break if interest_period.effect_date > Time.zone.today

      interest = interest_period.retained_per_annum
    end

    interest
  end

  def current_amount
    steps = current_amount_steps

    total_in = total_out = 0

    steps.each do |step|
      total_in += (step.in || 0)
      total_out += (step.out || 0)
    end

    total_in - total_out
  end

  def calc_balance(up_to_date = nil)
    up_to_date ||= DateTime.now.to_s

    steps = current_amount_steps(up_to_date)

    total_in = total_out = 0

    steps.each do |step|
      total_in += (step.in || 0)
      total_out += (step.out || 0)
    end

    total_in - total_out
  end

  def check_no(date_from, date_to, paid, payment_type)
    s_payments = if paid
                   payments.select do |x|
                     x.payment_kind.casecmp(payment_type).zero? && x.paid && x.paid_date >= date_from && x.paid_date <= date_to
                   end
                 else
                   payments.select do |x|
                     x.payment_kind.casecmp(payment_type).zero? && x.paid == false && x.due_date >= date_from && x.due_date <= date_to
                   end
                 end
    check_numbers = s_payments.map(&:check_no)
    check_numbers.delete('')
    check_numbers.delete(nil)
    check_numbers.join(', ')
  end

  def notify
    return unless is_notify_investor

    pdf = BuildSubInvestmentReportService.new.call(self)
    filename = "#{admin_user.name}'s subinvestment #{initial_description} #{Time.zone.today}".tr('/', '-')
    pdf.render_file "#{filename}.pdf"
    SubInvestmentMailer.sub_investment_mail(self, filename, target_email).deliver
    File.delete("#{filename}.pdf")
  end

  def principal_paid_date
    principal_paid? && principal_payment.paid_date ? principal_payment.paid_date : nil
  end

  def principal_due_date
    principal_payment&.due_date
  end

  def principal_paid?
    principal_payment&.paid
  end

  def target_emails
    target_email
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(
      account_id admin_user_id amount archive_date created_at creation_date currency current_accrued_amount
      current_retained_amount description envelope_id exchange_rate id initial_description investment_id
      investment_status_id is_notify_investor memo months name ori_amount private_note referrand_amount
      referrand_one_time_amount referrand_one_time_date referrand_percent referrand_scheduled referrand_user_id
      remote_agreement_url scheduled signed_agreement_url sub_investment_kind_id sub_investment_source_id
      transfer_from_id updated_at
    )
  end

  def self.ransackable_associations(_auth_object = nil)
    %w(
      account admin_user events interest_periods investment investment_status payments remote_agreement_attachment
      remote_agreement_blob signed_agreement_attachment signed_agreement_blob sub_distributions tasks transfer_from
      transferred_to withdraws
    )
  end

  def interest_date(num)
    interest_periods[num]&.effect_date
  end

  def interest_month_year(num)
    interest_periods[num] ? "#{interest_periods[num]&.per_annum}%" : ''
  end

  def interest_accrued(num)
    interest_periods[num] ? "#{interest_periods[num]&.accrued_per_annum}%" : ''
  end

  private

  def set_investment_kind_and_source
    self.sub_investment_kind_id = investment&.investment_kind&.name
    self.sub_investment_source_id = investment&.investment_source&.name
  end

  def set_default_attributes
    return unless scheduled.nil?

    self.scheduled = 'Monthly'
    self.currency = 'CAD'
    # referrand
    self.referrand_scheduled = 'Monthly'
    self.referrand_one_time_date = Time.zone.today
  end

  def set_interest_period
    interest_periods.build if new_record? && interest_periods.empty?
  end

  def set_default_status
    return unless investment_status_id.nil?

    self.investment_status ||= InvestmentStatus.active_status
  end

  def set_ori_amount
    self.ori_amount = amount
  end

  def handle_transfer
    return unless transfer_from

    transfer_from.withdraws.create!(amount: amount, admin_user_id: admin_user_id, due_date: start_date,
                                    is_transfer: true, transfer_to: self, paid: true, paid_date: Time.zone.today)

    transfer_param = {
      sub_distribution_type: 'Transfer',
      is_notify_investor: true,
      sub_investment_id: transfer_from.id,
      transfer_to_id: id,
      origin_amount: transfer_from.amount,
      target_amount: 0,
      admin_user_id: transfer_from.admin_user_id,
      amount: amount,
      date: start_date,
    }
    sub_distribution = SubDistribution.new(transfer_param)
    sub_distribution.skip_make_payment_or_transfer = true
    sub_distribution.save!
  end

  # payments on the 01.01.year should always be paid on 31.12.year-before
  # because tex reason
  def calculate_payment_date(date)
    (date.month == 1) && (date.day == 1) ? (date - 1) : date
  end

  def clear_account
    self.account = nil if investment.investment_source.try(:name) == 'ICIC'
  end

  def common_pay(date, amount, kind, memo, to)
    pay_date = calculate_payment_date(date)
    payment_data = {
      sub_investment_id: id,
      due_date: pay_date,
      amount: amount,
      admin_user_id: to,
      memo: memo.capitalize,
      payment_kind: kind,
      currency: currency,
    }
    payment = Payment.where(due_date: pay_date, sub_investment_id: id, payment_kind: kind).first_or_create
    payment.update(payment_data) unless payment.paid
    payment
  end

  def max_transfer_amount
    return unless new_record? && transfer_from && amount && (amount > transfer_from.amount)

    errors.add(:amount, "The max transfer amount is #{transfer_from.amount}")
  end

  def require_account
    investment_source = investment&.investment_source
    return unless investment_source&.imor? && account.nil?

    errors.add(:account, "can't be blank")
  end

  def log_events
    return unless months_changed? && months_was

    log_event "Term (months) changed from #{months_was} to #{months}"
  end

  def exchange_rate_required
    return unless currency != investment&.currency && exchange_rate.blank?

    errors.add(:exchange_rate, "can't be blank")
  end

  def current_accrued_common(start_date = nil, end_date = nil, paid: false)
    accrued_current(start_date, end_date, paid: paid).final_amount
  end

  def accrued_current(start_date = nil, end_date = nil, paid: false)
    @accrued_current ||= begin
      accrued_current = AccruedCurrent.new(self, start_date, end_date, paid: paid)
      accrued_current.compute_amount
      accrued_current
    end
  end

  def current_retained_common(start_date = nil, end_date = nil, paid: false)
    retained_current(start_date, end_date, paid: paid).final_amount
  end

  def retained_current(start_date = nil, end_date = nil, paid: false)
    @retained_current ||= begin
      retained_current = RetainedCurrent.new(self, start_date, end_date, paid: paid)
      retained_current.compute_amount
      retained_current
    end
  end

  def current_misc_common(start_date = nil, end_date = nil, paid: false)
    misc_current(start_date, end_date, paid: paid).final_amount
  end

  def misc_current(start_date = nil, end_date = nil, paid: false)
    @misc_current ||= begin
      misc_current = MiscCurrent.new(self, start_date, end_date, paid: paid)
      misc_current.compute_amount
      misc_current
    end
  end

  def principal_payment
    @principal_payment ||= payments.where(payment_kind: Payment::Type_Principal).first
  end

  def set_name
    self.name = if admin_user.present?
                  "#{admin_user.name}-#{investment.name}-#{currency} #{creation_date}"
                else
                  'x'
                end
  end

  def update_payment_source_flag
    return unless investment.investment_source

    payments.update(source_flag: investment.investment_source.name)
  end

  def adjust_investment_amount
    UpdateInvestmentStatsWorker.perform_async(investment_id)
  end

  def update_status
    if amount.zero?
      # not archive automatically
      self.investment_status = InvestmentStatus.archive_status
      self.archive_date = Time.zone.today
    else
      self.investment_status = InvestmentStatus.active_status
      self.archive_date = nil
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Security/Open
# rubocop:enable Metrics/ParameterLists
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity
