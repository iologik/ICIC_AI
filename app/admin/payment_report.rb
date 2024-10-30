# frozen_string_literal: true

ActiveAdmin.register PaymentReport do
  menu parent: 'Reports'

  actions :all, except: %i(edit update new create)

  config.sort_order = nil
  # config.filters = true
  config.batch_actions = false

  scope :due_next_month_cad, default: true
  scope :due_next_month_usd

  filter :investment_source_id, label: 'Investment Source', as: :select,
                                collection: InvestmentSource.pluck(:name, :id)

  index do
    div class: 'hide payment-report-total' do
      result = 0
      payment_reports.each do |r|
        result += r.amount
      end
      number_to_currency(result, precision: 2)
    end

    column :due_date
    column 'Sub Investor' do |item|
      link_to item.name, admin_sub_investor_path(item.admin_user_id)
    end
    column :amount do |item|
      number_to_currency(item.amount, precision: 2)
    end
    column :currency
  end
end
