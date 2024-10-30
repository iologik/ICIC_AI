# frozen_string_literal: true

# == Schema Information
#
# Table name: sub_distributions
#
#  id                    :integer          not null, primary key
#  amount                :decimal(12, 2)
#  check_no              :string
#  date                  :date
#  is_notify_investor    :boolean
#  origin_amount         :decimal(, )
#  sub_distribution_type :string(255)
#  target_amount         :decimal(, )
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  admin_user_id         :integer
#  sub_investment_id     :integer
#  transfer_to_id        :integer
#
# Indexes
#
#  index_sub_distributions_on_transfer_to_id  (transfer_to_id)
#
class SubDistribution < ApplicationRecord
  include TargetEmail

  attr_accessor :skip_make_payment_or_transfer, :current_admin_user_id

  belongs_to :sub_investment, optional: true
  belongs_to :transfer_to, class_name: 'SubInvestment', optional: true
  belongs_to :admin_user, optional: true

  validates :sub_investment_id, :amount, :date, presence: true

  validates :transfer_to_id, presence: true, if: proc { |sub_distribution|
                                                   sub_distribution.sub_distribution_type == 'Transfer'
                                                 }

  before_save :set_admin_user
  after_create :make_payment_or_transfer
  after_commit :notify_investor

  skip_callback :create, :after, :make_payment_or_transfer, if: :skip_make_payment_or_transfer

  def self.by_investment
    joins(:sub_investment)
      .joins('left join investments on sub_investments.investment_id=investments.id')
      .joins('left join admin_users on sub_investments.admin_user_id=admin_users.id')
      .where('investments.id=?', Thread.current['investment_for_sub_distributions'])
      .order('sub_distributions.date asc, admin_users.last_name asc, admin_users.first_name asc')
  end

  def self.amount_by_investment(investment_id)
    sql = <<-SQL.squish
      select sum(sub_distributions.amount) from sub_distributions
      left join sub_investments on sub_distributions.sub_investment_id = sub_investments.id
      left join investments on sub_investments.investment_id = investments.id
      where investments.id = #{investment_id}
    SQL
    sanitized_sql = ActionController::Base.helpers.sanitize(sql)
    ApplicationRecord.connection.execute(sanitized_sql).first['sum'].to_f
  end

  def target_emails
    target_email
  end

  private

  def set_admin_user
    self.admin_user_id = sub_investment.admin_user_id
  end

  def build_return_capital_investor
    ReturnCapitalInvestor.create! admin_user_id: sub_investment.admin_user_id, sub_investment_id: sub_investment.id,
                                  amount: amount, due_date: date
  end

  def make_payment_or_transfer
    if transfer_to
      # apply currency rate if currency different
      sub_investment.transfer_to(transfer_to_id, amount, date, check_no)
    else
      build_return_capital_investor
    end
  end

  def notify_investor
    return unless is_notify_investor

    SubDistributionNotifyInvestorWorker.perform_in(5.seconds, id)
  end
end
