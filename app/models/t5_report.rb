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
class T5Report < Payment
  # not include imor
  def self.search_sql(year, currency, investment_source_ids, payment_type_param)
    investment_source_ids = InvestmentSource.pluck(:id) if investment_source_ids.blank?

    payment_types = ''
    payment_type_param.each do |type|
      payment_types += "'#{type}',"
    end

    payment_types = payment_types[0..-2] if payment_types.last == ','

    %(
      select admin_users.id, MAX(admin_users.last_name || ' ' || admin_users.first_name) as name,
           MAX(admin_users.address || ' ' || admin_users.city || ' ' || admin_users.province || ' ' || admin_users.country) as address,
           sum(payments.amount) as #{currency.downcase}_amount, MAX(payments.source_flag) as source_flag, investments.investment_source_id as source_id
      from payments
      left join sub_investments on payments.sub_investment_id = sub_investments.id
      left join investments on sub_investments.investment_id = investments.id
      left join admin_users on payments.admin_user_id=admin_users.id
      left join investment_sources on investments.investment_source_id=investment_sources.id
      where to_char(paid_date, 'YYYY')='#{year}' and sub_investments.currency='#{currency}'
            and investments.investment_source_id in (#{investment_source_ids.join(',')})
            and paid='t' and payment_kind in (#{payment_types})
      group by admin_users.id, investments.investment_source_id
    )
  end

  # rubocop:disable Metrics/AbcSize
  def self.payments_by_year(year, investment_source_ids, payment_type)
    cad_sql = search_sql(year, 'CAD', investment_source_ids, payment_type)
    cad_hash = ApplicationRecord.connection.execute(cad_sql).to_a.index_by do |value|
      "#{value['id']}#{value['source_flag']}"
    end

    usd_sql = search_sql(year, 'USD', investment_source_ids, payment_type)
    usd_hash = ApplicationRecord.connection.execute(usd_sql).to_a.index_by do |value|
      "#{value['id']}#{value['source_flag']}"
    end

    result = []
    (cad_hash.keys + usd_hash.keys).uniq.each do |id|
      result << (cad_hash[id] || {}).merge(usd_hash[id] || {})
    end

    result.sort_by { |a| a['name'] }.sort_by { |a| a['source_flag'] }
  end
  # rubocop:enable Metrics/AbcSize
end
