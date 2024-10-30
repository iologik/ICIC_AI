# frozen_string_literal: true

namespace :payment do
  # TODO: this could be remove
  task report: :environment do
    imor_id = InvestmentSource.imor.id

    sql = <<-SQL
      CREATE VIEW payment_reports AS
        select  payments.admin_user_id || sub_investments.currency || to_char(payments.due_date, 'YYYY-MM-DD') as id ,
          payments.admin_user_id, due_date, sum(payments.amount) as amount,sub_investments.currency,(admin_users.last_name || admin_users.first_name) as name
          from payments
          left join sub_investments on payments.sub_investment_id=sub_investments.id
          left join investments on sub_investments.investment_id=investments.id
          left join admin_users on payments.admin_user_id=admin_users.id
          where paid='f' and investment_source_id != #{imor_id}
          group by payments.admin_user_id, admin_users.last_name, admin_users.first_name, payments.due_date, sub_investments.currency
          order by payments.due_date, admin_users.last_name, admin_users.first_name;
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  task set_paid_date: :environment do
    ActiveRecord::Base.connection.execute('update payments SET paid_date=due_date')
    puts '---------------setting paid date done------------------'
  end
end
