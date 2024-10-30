# frozen_string_literal: true

# == Schema Information
#
# Table name: loans
#
#  id          :integer          not null, primary key
#  borrower_id :integer
#  ori_amount  :decimal(12, 2)
#  amount      :decimal(12, 2)
#  start_date  :date
#  currency    :string(255)
#  scheduled   :string(255)
#  months      :integer
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string(255)
#
class Loan < ApplicationRecord
  validates :name, presence: true
  validates :borrower, presence: true
  validates :months, numericality: { less_than_or_equal_to: 60, greater_than: 0 }, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, presence: true # amount can be 0 because withdraw

  has_many :loan_interest_periods, dependent: :destroy
  has_many :loan_payments, dependent: :destroy
  has_many :loan_draws, dependent: :destroy
  belongs_to :borrower, optional: true

  accepts_nested_attributes_for :loan_interest_periods

  after_initialize :set_interest_period
  before_create :set_ori_amount

  after_save :adjust_payment # generate payments after save loan

  def display_name
    name
  end

  def start_date
    @first_interest_period ||= loan_interest_periods.order('effect_date asc').limit(1).first
    @first_interest_period.try(:effect_date)
  end

  def per_annum
    loan_interest_periods.reorder('effect_date desc').each do |ip|
      return ip.per_annum if ip.effect_date <= Time.zone.today
    end
    loan_interest_periods.first.try(:per_annum)
  end

  # rubocop:disable Metrics/AbcSize
  def adjust_payment
    return if per_annum.nil?
    return if amount.nil?

    # delete unpaid payments
    loan_payments.each { |o| o.destroy unless o.paid }

    # monthly/quarterly payments
    if monthly?
      MonthPaymentLoan.new(self).set_termly_payments
    elsif quarterly?
      QuarterPaymentLoan.new(self).set_termly_payments
    else
      AnnualPaymentLoan.new(self).set_termly_payments
    end
  end

  def current_amount_steps
    @current_amount_steps ||= begin
      steps = []
      steps << Obj.new(start_date, 'Initial amount', ori_amount, nil, ori_amount)
      current_amount = ori_amount
      loan_draws.order('due_date').each do |withdraw|
        if withdraw.instance_of?(CashBack)
          action = 'Cash Back'
          if (payment = LoanPayment.payment_for_cash_back(withdraw)).paid
            current_amount -= withdraw.real_amount
            steps << Obj.new(payment.due_date, action, nil, withdraw.amount, current_amount)
          end
        else
          action = 'Draw'
          current_amount -= withdraw.real_amount
          steps << Obj.new(withdraw.due_date, action, withdraw.amount, nil, current_amount)
        end
      end
      # return
      steps
    end
  end
  # rubocop:enable Metrics/AbcSize

  def affect_investment(affect_amount)
    new_amount    = amount - affect_amount
    sql           = "update loans set amount = #{new_amount} where id=#{id}"
    sanitized_sql = ActionController::Base.helpers.sanitize(sql)
    SubInvestment.connection.execute(sanitized_sql)
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

  def last_paid_date
    payment = loan_payments.where(paid: true).order('due_date desc').first
    payment&.due_date
  end

  class Obj
    def initialize(date, action, amount_in, amount_out, balance)
      @date = date
      @action = action
      @in = amount_in
      @out = amount_out
      @balance = balance
    end

    def to_key
      nil
    end

    attr_accessor :date, :action, :in, :out, :balance
  end

  def self.ransackable_associations(_auth_object = nil)
    %w(borrower loan_draws loan_interest_periods loan_payments)
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(amount borrower_id created_at currency description id months name ori_amount scheduled start_date updated_at)
  end

  private

  def set_interest_period
    loan_interest_periods.build if new_record? && loan_interest_periods.empty?
  end

  def set_ori_amount
    self.ori_amount = amount
  end
end
