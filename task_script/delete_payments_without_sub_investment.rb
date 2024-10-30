# frozen_string_literal: true

sql = %(
select * from (
SELECT "payments".sub_investment_id FROM "payments" left join sub_investments on payments.sub_investment_id=sub_investments.id
) t where sub_investment_id not in
(select id from sub_investments);
)

results = ActiveRecord::Base.connection.execute(sql)

sub_investment_ids = results.map { |x| x['sub_investment_id'] }

Payment.where(sub_investment_id: sub_investment_ids).find_each do |payment|
  puts "#{payment.id},#{payment.paid}"
  payment.destroy unless payment.paid
end
