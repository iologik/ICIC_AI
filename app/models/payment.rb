# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                    :integer          not null, primary key
#  amount                :decimal(12, 2)
#  check_no              :string(255)
#  currency              :string(255)
#  due_date              :date
#  investment_name       :string
#  is_resend_statement   :boolean
#  memo                  :text
#  paid                  :boolean          default(FALSE), not null
#  paid_date             :date
#  payment_kind          :string(255)
#  rate                  :decimal(, )
#  remark                :text
#  source_flag           :string(255)
#  start_date            :date
#  sub_investment_amount :decimal(12, 2)
#  sub_investor_name     :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  admin_user_id         :integer
#  sub_investment_id     :integer
#  withdraw_id           :integer
#
# Indexes
#
#  index_payments_on_admin_user_id      (admin_user_id)
#  index_payments_on_sub_investment_id  (sub_investment_id)
#  index_payments_on_withdraw_id        (withdraw_id)
#
class Payment < ApplicationRecord
  belongs_to :admin_user
  belongs_to :sub_investment
  belongs_to :withdraw, optional: true
  delegate :investment_source, to: :sub_investment

  before_save :generate_names
  before_create :build_source
  after_save :resend_statement
  # after_save :adjust_sub_investment, if: :amount_changed?
  # after_create :adjust_sub_investment
  # after_destroy :adjust_sub_investment

  scope :all_payments, lambda {
                         joins(:admin_user).order('due_date ASC')
                       } # do not use all as scope, because all is already defined for ApplicationRecord
  scope :pending,   -> { joins(:admin_user).where(paid: false).order('due_date ASC') }
  scope :paid,      -> { joins(:admin_user).where(paid: true).order('due_date ASC') }
  scope :interest,  -> { where(payment_kind: 'Interest') }
  scope :AMF,       -> { where(payment_kind: 'AMF') }
  scope :principal, -> { where(payment_kind: 'Principal') }

  # rubocop:disable Naming/ConstantName
  Type_Interest      = 'Interest'
  Type_AMF           = 'AMF'
  Type_Principal     = 'Principal'
  Type_Withdraw      = 'Withdraw'
  Type_Accrued       = 'Accrued' # bonus
  Type_Retained      = 'Retained' # bonus
  Type_Transfer      = 'Transfer'
  Type_Misc_Interest = 'MISC'
  # rubocop:enable Naming/ConstantName

  validates :payment_kind, presence: true

  validate :correct_payment_type!
  validate :paid_date!

  require 'csv' # TODO: require should not be called here

  def self.payments_kinds_page
    @payments_kinds_page ||= [
      [Type_Interest, Type_Interest],
      [Type_AMF, Type_AMF],
      [Type_Principal, Type_Principal],
      [Type_Withdraw, Type_Withdraw],
      ['ACCRUED INTEREST', Type_Accrued],
      ['INTEREST RESERVE', Type_Retained],
      [Type_Transfer, Type_Transfer],
      [Type_Misc_Interest, Type_Misc_Interest],
    ].sort
  end

  # rubocop:disable Metrics/AbcSize
  def self.export
    CSV.generate do |csv|
      csv << ['!TRNS', 'TRNSID',	'TRNSTYPE', 'DATE',	'ACCNT', 'NAME',	'CLASS',	'AMOUNT', 'DOCNUM', 'MEMO',	'CLEAR',
              'TOPRINT', 'ADDR5', 'DUEDATE',	'TERMS']
      csv << ['!SPL', 'SPLID', 'TRNSTYPE', 'DATE',	'ACCNT', 'NAME',	'CLASS', 'AMOUNT', 'DOCNUM', 'MEMO', 'CLEAR',
              'QNTY', 'REIMBEXP', 'SERVICEDATE', 'OTHER2']
      csv << ['!ENDTRNS']
      find_each do |payment|
        # not include imor investments, but include all others
        next if payment.sub_investment.investment.investment_source == InvestmentSource.imor

        if payment.sub_investment.currency.present? && payment.sub_investment.currency.include?('CAD')
          acc = 'Accounts Payable'
          acc2 = 'Revenue 1'
        else
          acc = 'Accounts Payable - USD'
          acc2 = 'Revenue 2'
        end
        csv << ['TRNS', '', 'BILL', payment.due_date.strftime('%m/%d/%y'), acc, 'class', payment.admin_user.name, payment.amount,
                '', payment.memo, 'N', 'N', '', payment.due_date.strftime('%m/%d/%y')]
        csv << ['SPL', '', 'BILL', payment.due_date.strftime('%m/%d/%y'), acc2, 'class', '', payment.amount, '', '', '', 'N', '',
                'NOTHING', '0/0/0', '']
        csv << ['ENDTRNS']
      end
    end
  end

  def self.due_next_month(source = 'all', currency = nil)
    due_sql = sanitize_sql("due_date >= '#{Time.zone.today.at_beginning_of_month}' and due_date <= '#{Time.zone.today.at_end_of_month + 1.month}' and paid = ?")
    if source == 'all'
      result = where(due_sql, false)
    else
      join_sql = Payment.joins(:sub_investment)
                        .joins('left join investments on sub_investments.investment_id=investments.id')
                        .joins(:admin_user)
      imor_id = InvestmentSource.imor.id
      result  = if source == 'icic'
                  # icic investments include other investments except imor
                  join_sql.where("#{due_sql} and investment_source_id != ? and sub_investments.currency = ?", false, imor_id, currency)
                else
                  join_sql.where("#{due_sql} and investment_source_id = ?", false, imor_id)
                end
    end
    result.order('admin_users.last_name asc, admin_users.first_name asc, due_date asc')
  end
  # rubocop:enable Metrics/AbcSize

  def self.due_next_month_cad
    where(due_date: Time.zone.today.at_beginning_of_month..(Time.zone.today.at_end_of_month + 1.month), paid: false, currency: 'CAD')
  end

  def self.due_next_month_usd
    where(due_date: Time.zone.today.at_beginning_of_month..(Time.zone.today.at_end_of_month + 1.month), paid: false, currency: 'USD')
  end

  def self.due_next_month_other
    due_next_month 'other'
  end

  def self.account_sort_imor
    due_next_month('other').joins('left join accounts on sub_investments.account_id=accounts.id').reorder('accounts.name asc, admin_users.last_name asc, admin_users.first_name asc, due_date asc')
  end

  def self.payment_for_withdraw(withdraw)
    return withdraw.payment if withdraw.payment

    kind = if withdraw.is_transfer
             Type_Transfer
           else
             Type_Withdraw
           end
    withdraw.sub_investment.payments.where(payment_kind: kind, due_date: withdraw.due_date).first
  end

  class << self
    alias imor due_next_month_other
    alias rrsp imor
  end

  def paid!(check_no = 'PAID', due_date = nil, paid_date = nil)
    self.check_no = check_no
    self.paid = true
    self.due_date = due_date if (payment_kind == Type_Withdraw || payment_kind == Type_Transfer || payment_kind == Type_Principal) && due_date.present?
    self.paid_date = paid_date
    save!
  end

  def pending!
    self.check_no = nil
    self.paid = false
    save!
  end

  def status
    # TODO: Not sure about this change
    # if self.check_no.nil?
    #	"Pending"
    # else
    #	"Paid"
    # end
    if paid
      'Paid'
    else
      'Pending'
    end
  end

  delegate :to_s, to: :id

  def ownership_amount
    if sub_investment.different_currency?
      amount * (ExchangeRate.exchange_rate_by(due_date, sub_investment.currency) || 1)
    else
      amount
    end
  end

  def amf_payment?
    payment_kind == Type_AMF
  end

  def misc_payment?
    payment_kind == Type_Misc_Interest
  end

  def pay_payment?(pending_to_paid)
    paid && (created_at == updated_at || pending_to_paid) # paid_was maybe nil
  end

  def unpaid_payment?(paid_to_pending)
    paid == false && paid_to_pending
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(
      admin_user_id amount check_no created_at currency due_date id investment_name is_resend_statement
      memo paid paid_date payment_kind rate remark source_flag start_date sub_investment_amount
      sub_investment_id sub_investor_name updated_at withdraw_id
    )
  end

  def self.ransackable_associations(_auth_object = nil)
    %w(admin_user sub_investment withdraw)
  end

  private

  # TODO: add test for paid_callback

  def build_source
    return '' unless sub_investment.investment
    return '' unless (investment_source = sub_investment.investment.investment_source)

    self.source_flag = investment_source.name
  end

  def generate_names
    return unless sub_investment.investment

    self.sub_investor_name = admin_user.name
    self.investment_name = sub_investment.investment.name
  end

  def correct_payment_type!
    unless payment_kind.in?([Type_Interest, Type_AMF, Type_Principal, Type_Withdraw, Type_Accrued, Type_Retained,
                             Type_Transfer, Type_Misc_Interest])
      errors.add(:payment_kind,
                 "Payment type must be one of #{Type_Interest}, #{Type_AMF}, #{Type_Principal}, #{Type_Withdraw}, #{Type_Accrued}, #{Type_Retained}, #{Type_Transfer}, #{Type_Misc_Interest}")
    end
  end

  def paid_date!
    return unless paid? && paid_date.nil?

    errors.add(:paid_date, "Paid date must be provided if it's paid")
  end

  def resend_statement
    return unless is_resend_statement

    SendPaymentEmailService.new.call([self])
  end

  def adjust_sub_investment
    return unless (amf_payment? && sub_investment.amount.zero?) || paid

    sub_investment.adjust_amount
  end
end
