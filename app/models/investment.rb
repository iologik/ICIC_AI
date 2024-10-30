# frozen_string_literal: true

# == Schema Information
#
# Table name: investments
#
#  id                        :integer          not null, primary key
#  accrued_payable_amount    :decimal(, )
#  address                   :string(255)
#  all_paid_payments_amount  :decimal(, )
#  amount                    :decimal(12, 2)
#  archive_date              :date
#  cad_money_raised_amount   :decimal(12, 2)
#  cash_reserve_amount       :decimal(12, 2)
#  currency                  :string(255)
#  description               :text
#  distrib_cash_reserve      :decimal(, )
#  distrib_gross_profit      :decimal(, )
#  distrib_holdback_state    :decimal(, )
#  distrib_net_cash          :decimal(, )
#  distrib_return_of_capital :decimal(, )
#  distrib_withholding_tax   :decimal(, )
#  distribution_draw_amount  :decimal(, )
#  draw_amount               :decimal(, )
#  exchange_rate             :float
#  expected_return_percent   :float
#  fee_amount                :decimal(, )
#  fee_type                  :string
#  gross_profit_total_amount :decimal(, )
#  icic_committed_capital    :decimal(, )
#  image_url                 :string(255)
#  initial_description       :text
#  legal_name                :string(255)
#  location                  :string(255)
#  memo                      :string(120)
#  money_raised_amount       :decimal(12, 2)
#  name                      :string(255)
#  net_income_amount         :decimal(, )
#  ori_amount                :decimal(12, 2)
#  postal_code               :string
#  private_note              :text
#  retained_payable_amount   :decimal(, )
#  start_date                :date
#  sub_accrued_percent_sum   :decimal(, )
#  sub_amount_total          :decimal(, )
#  sub_balance_amount        :decimal(, )
#  sub_ownership_percent_sum :decimal(, )
#  sub_per_annum_sum         :decimal(, )
#  sub_retained_percent_sum  :decimal(, )
#  year_paid                 :decimal(, )
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  investment_kind_id        :integer
#  investment_source_id      :integer
#  investment_status_id      :integer
#
# Indexes
#
#  index_investments_on_investment_kind_id    (investment_kind_id)
#  index_investments_on_investment_source_id  (investment_source_id)
#  index_investments_on_investment_status_id  (investment_status_id)
#
class Investment < ApplicationRecord
  has_paper_trail

  validates :amount, presence: true
  validates :start_date, presence: true

  # belongs_to :admin_user
  belongs_to :investment_source
  belongs_to :investment_kind
  belongs_to :investment_status

  has_many :sub_investments, dependent: :destroy
  has_many :distributions, dependent: :destroy
  has_many :draws, dependent: :destroy
  has_many :posts, dependent: :destroy

  has_many :payments, through: :sub_investments

  has_many_attached :images

  before_save :set_investment_status
  before_create :set_ori_amount
  after_create :initialize_draw
  after_save :restructure_attachments
  after_commit :update_dashboard_values

  default_scope { order('investments.name asc') }

  attr_accessor :balance

  def paid_payment_amount(payment_kind)
    Payment.joins('left join sub_investments on payments.sub_investment_id = sub_investments.id')
           .joins('left join investments on sub_investments.investment_id = investments.id')
           .where('investments.id = ? and payments.paid = ? and payments.payment_kind = ?', id, true, payment_kind)
           .select('sum(payments.amount) as amount').first.amount
  end

  def gross_profit_total
    @gross_profit_total ||= distributions.inject(0) do |r, d|
      r += d.gross_profit
      r
    end || 0
  end

  def gross_profit_total_by_date(date)
    distributions.where('date <= ?', date).inject(0) do |r, d|
      r += d.gross_profit
      r
    end || 0
  end

  def gross_profit_total_between(from_date, to_date)
    distributions.where('date >= ? and date <= ?', from_date, to_date).inject(0) do |r, d|
      r += d.gross_profit
      r
    end || 0
  end

  def all_paid_payments
    @all_paid_payments ||= begin
      payments = Payment.joins('left join sub_investments on payments.sub_investment_id = sub_investments.id')
                        .joins('left join investments on sub_investments.investment_id = investments.id')
                        .where('investments.id' => id, 'payments.paid' => true,
                               'payments.payment_kind' => [Payment::Type_Interest, Payment::Type_AMF, Payment::Type_Accrued, Payment::Type_Retained])
      payments.inject(0) do |result, payment|
        result += payment.ownership_amount
        result
      end
    end
  end

  def all_paid_payments_amount_by_date(date)
    payments = Payment.joins('left join sub_investments on payments.sub_investment_id = sub_investments.id')
                      .joins('left join investments on sub_investments.investment_id = investments.id')
                      .where('investments.id = ? and payments.paid = ? and payments.payment_kind in (?) and payments.due_date <= ?',
                             id, true, [Payment::Type_Interest, Payment::Type_AMF, Payment::Type_Accrued, Payment::Type_Retained], date)
    payments.inject(0) do |result, payment|
      result += payment.ownership_amount
      result
    end
  end

  def all_paid_payments_amount_between(from_date, end_date)
    payments = Payment.joins('left join sub_investments on payments.sub_investment_id = sub_investments.id')
                      .joins('left join investments on sub_investments.investment_id = investments.id')
                      .where('investments.id = ? and payments.paid = ? and payments.payment_kind in (?) and payments.due_date >= ? and payments.due_date <= ?',
                             id, true, [Payment::Type_Interest, Payment::Type_AMF, Payment::Type_Accrued, Payment::Type_Retained], from_date, end_date)
    payments.inject(0) do |result, payment|
      result += payment.ownership_amount
      result
    end
  end

  def sub_balance
    @sub_balance ||= gross_profit_total - all_paid_payments_amount
  end

  def sub_balance_by_date(date)
    gross_profit_total_by_date(date) - all_paid_payments_amount_by_date(date)
  end

  def sub_balance_between(start_date, end_date)
    gross_profit_total_between(start_date, end_date) - all_paid_payments_amount_between(start_date, end_date)
  end

  def accrued_payable
    @accrued_payable ||= (sub_investments.sum(&:current_accrued) || 0)
  end

  def accrued_until_this_year
    @accrued_until_this_year ||= sub_investments.sum do |subinvest|
      subinvest.current_accrued(nil, Time.zone.today)
    end || 0
  end

  def retained_payable
    @retained_payable ||= (sub_investments.sum(&:current_retained) || 0)
  end

  def retained_until_this_year
    @retained_until_this_year ||= sub_investments.sum do |subinvest|
      subinvest.current_retained(nil, Time.zone.today)
    end || 0
  end

  def net_income
    @net_income ||= (gross_profit_total - all_paid_payments_amount - accrued_payable - retained_payable)
  end

  def self.total
    total = 0
    Investment.find_each { |i| total += i.amount.to_i }
    total
  end

  def self.active
    if Thread.current['visit_index']
      where(investment_status_id: [InvestmentStatus.active_status.id, InvestmentStatus.future.id]).eager_load(
        :sub_investments, :distributions
      )
    else
      eager_load(:sub_investments, :distributions)
    end
  end

  # TODO: this will make the investment be loaded again from database, why? (Admin Investments page)
  def money_raised
    @money_raised ||= sub_investments.sum(&:ownership_amount)
  end

  def adjust_money_raised_amount
    update(money_raised_amount: money_raised)
  end

  def cash_reserve
    @cash_reserve ||= distributions.inject(0) do |r, distribution|
      r += (distribution.cash_reserve || 0)
      r
    end
  end

  def adjust_cash_reserve_amount
    update(cash_reserve_amount: cash_reserve)
  end

  def cad_cash_reserve_amount
    @cad_cash_reserve_amount ||= if currency == 'CAD'
                                   cash_reserve_amount
                                 else
                                   cash_reserve_amount * ExchangeRate.now_usd_to_cad_rate
                                 end
  end

  def cad_money_raised
    @cad_money_raised ||= sub_investments.inject(0) do |r, sub_invest|
      r += sub_invest.cad_amount
      r
    end
  end

  def adjust_cad_money_raised_amount
    update(cad_money_raised_amount: cad_money_raised)
  end

  def cad_amount
    @cad_amount ||= if currency == 'CAD'
                      amount
                    else
                      amount * ExchangeRate.now_usd_to_cad_rate
                    end
  end

  def main_image
    @main_image ||= all_images[0]
  end

  def all_images
    return images.map { |image| image.service_url.sub(/\?.*/, '') } if images.count.positive?

    @all_images ||= begin
      all_images = []
      posts.order('id desc').each do |post|
        images = post.body.scan(/img src="([^"]+)"/i).pluck(0)
        all_images += images
      end
      all_images
    end
  end

  def other_images
    @other_images ||= all_images - [main_image]
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def distribution_by_year(year)
    @distribution_by_year ||= {}
    @distribution_by_year[year] ||= begin
      distribution_draws = (distributions.to_a + draws.to_a).sort_by(&:date)
      current_amount = ori_amount

      distribution_draws.each_with_index do |distribution_draw, i|
        if (distribution_draw.date.year > year) || i == (distribution_draws.length - 1)
          break # NOTE: here
        end

        if i.positive?
          if distribution_draw.instance_of?(Draw)
            current_amount += distribution_draw.amount
          else
            current_amount -= distribution_draw.return_of_capital
          end
        end
      end

      current_amount
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  def imor?
    investment_source == InvestmentSource.imor
  end

  def self.cwt_investment_id
    55
  end

  def ici_usa?
    investment_source == InvestmentSource.ici_usa
  end

  def self.latest_rate(src = 'USD')
    if src == 'USD'
      ExchangeRate.now_usd_to_cad_rate
    else
      ExchangeRate.now_cad_to_usd_rate
    end
  end

  def self.recent_images
    recent_images = []
    Investment.where(investment_status_id: InvestmentStatus.active_status.id).reorder(updated_at: :desc).find_each do |invest|
      recent_images.concat invest.all_images

      break if recent_images.length >= 10
    end

    recent_images
  end

  def current_amount
    amount = 0

    draws.each do |draw|
      amount += draw.amount
    end

    distributions.each do |distribution|
      amount -= distribution.return_of_capital
    end

    amount
  end

  def adjust_amount
    update(amount: current_amount)
  end

  def calc_balance(start_date = nil, end_date = nil)
    amount = 0

    start_date = start_date.present? ? DateTime.parse(start_date) : DateTime.parse('1999-1-1')
    end_date = end_date.present? ? DateTime.parse(end_date) : DateTime.parse('2999-1-1')

    draws.where(created_at: start_date..end_date).find_each do |draw|
      amount += draw.amount
    end

    distributions.where(created_at: start_date..end_date).find_each do |distribution|
      amount -= distribution.return_of_capital
    end

    amount
  end

  def adjust_amounts
    adjust_amount
    adjust_money_raised_amount
    adjust_cad_money_raised_amount
    adjust_cash_reserve_amount
  end

  def distribution_draws
    (distributions.to_a + draws.to_a).sort_by(&:date)
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(
      accrued_payable_amount address all_paid_payments_amount amount
      archive_date cad_money_raised_amount cash_reserve_amount created_at
      currency description distrib_cash_reserve distrib_gross_profit
      distrib_holdback_state distrib_net_cash distrib_return_of_capital
      distrib_withholding_tax distribution_draw_amount draw_amount exchange_rate
      expected_return_percent fee_amount fee_type gross_profit_total_amount
      icic_committed_capital id image_url initial_description
      investment_kind_id investment_source_id investment_status_id
      legal_name location memo money_raised_amount name
      net_income_amount ori_amount postal_code private_note
      retained_payable_amount start_date sub_accrued_percent_sum
      sub_amount_total sub_balance_amount sub_ownership_percent_sum
      sub_per_annum_sum sub_retained_percent_sum updated_at year_paid
    )
  end

  def self.ransackable_associations(_auth_object = nil)
    %w(
      distributions draws images_attachments images_blobs investment_kind
      investment_source investment_status payments posts sub_investments versions
    )
  end

  private

  def set_investment_status
    # if amount == 0
    #   # not archive automatically
    #   # self.investment_status = InvestmentStatus.archive_status
    #   self.archive_date = last_dist_draw_date
    # else
    #   self.investment_status = InvestmentStatus.active_status
    #   self.archive_date = nil
    # end
  end

  # will empty amount first, amount will be added back through initial draw
  def set_ori_amount
    self.ori_amount = amount
    self.amount = 0
  end

  def initialize_draw
    draws.create(amount: ori_amount, date: start_date,
                 description: (initial_description.presence || 'Initial amount'))
  end

  def last_dist_draw_date
    distribution_draws = (distributions.to_a + draws.to_a).sort_by(&:date)
    distribution_draws.last.try(:date)
  end

  def restructure_attachments
    images.each do |image|
      restructure_attachment(image, "uploads/#{id}/images/#{image.blob.filename}")
    end
  end

  # rubocop:disable Metrics/AbcSize
  def restructure_attachment(image, new_structure)
    return if image.key.include? '/images/'

    old_key = image.key

    begin
      # Passing S3 Configs
      config = YAML.safe_load(Rails.root.join('config', 'storage.yml'))

      s3 = Aws::S3::Resource.new(region: config['amazon']['region'],
                                 credentials: Aws::Credentials.new(ENV.fetch('aws_access_key_id', nil),
                                                                   ENV.fetch('aws_secret_access_key', nil)))

      # Fetching the licence's Aws::S3::Object
      old_obj = s3.bucket(ENV.fetch('bucket', nil)).object(old_key)

      # Moving the license into the new folder structure
      old_obj.move_to(bucket: ENV.fetch('bucket', nil), key: new_structure.to_s)

      update_blob_key(image, new_structure)
    rescue => e
      driver_helper_logger.error("Error restructuring license belonging to driver with id #{image.record.id}: #{e.full_message}")
    end
  end
  # rubocop:enable Metrics/AbcSize

  # The new structure becomes the new ActiveStorage Blob key
  def update_blob_key(image, new_key)
    blob = image.blob
    begin
      blob.key = new_key
      blob.save!
    rescue => e
      driver_helper_logger.error("Error reassigning the new key to the blob object of the driver with id #{image.record.id}: #{e.full_message}")
    end
  end

  def driver_helper_logger
    @driver_helper_logger ||= Logger.new(Rails.root.join('log', 'driver_helper.log', 'driver_helper.log').to_s)
  end

  def update_dashboard_values
    UpdateDashboardStatsWorker.perform_async
  end
end
