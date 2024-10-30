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
class UserPayment < Payment
  def self.current_year_cad
    payments_by_year(Time.zone.today.year, 'CAD')
  end

  def self.last_year_cad
    payments_by_year(Time.zone.today.year - 1, 'CAD')
  end

  def self.before_last_year_cad
    payments_by_year(Time.zone.today.year - 2, 'CAD')
  end

  def self.three_years_ago_cad
    payments_by_year(Time.zone.today.year - 3, 'CAD')
  end

  def self.current_year_usd
    payments_by_year(Time.zone.today.year, 'USD')
  end

  def self.last_year_usd
    payments_by_year(Time.zone.today.year - 1, 'USD')
  end

  def self.before_last_year_usd
    payments_by_year(Time.zone.today.year - 2, 'USD')
  end

  def self.three_years_ago_usd
    payments_by_year(Time.zone.today.year - 3, 'USD')
  end

  def self.payments_by_year(year, currency)
    joins('left join sub_investments on payments.sub_investment_id=sub_investments.id')
      .where("payments.admin_user_id=? and to_char(paid_date, 'YYYY')=? and sub_investments.currency=?", Thread.current['admin_user_id'], year.to_s, currency)
  end

  def self.all_payments
    joins('left join sub_investments on payments.sub_investment_id=sub_investments.id')
      .where('payments.admin_user_id=?', Thread.current['admin_user_id'])
  end

  # this is for the page actually
  # rubocop:disable Metrics/AbcSize
  def self.first_scope(sub_investor_id)
    Thread.current['admin_user_id'] = sub_investor_id
    return 'current_year_cad' if current_year_cad.count.positive?
    return 'current_year_usd' if current_year_usd.count.positive?
    return 'last_year_cad' if last_year_cad.count.positive?
    return 'last_year_usd' if last_year_usd.count.positive?
    return 'before_last_year_cad' if before_last_year_cad.count.positive?

    'before_last_year_usd' # NOTE: return this one anyway before_last_year_usd has records
  end
  # rubocop:enable Metrics/AbcSize
end
