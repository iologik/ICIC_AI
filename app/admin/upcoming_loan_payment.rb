# frozen_string_literal: true

ActiveAdmin.register UpcomingLoanPayment do
  menu parent: 'Loan Tables'

  actions :all, except: %i(edit update new create destroy)

  config.sort_order = nil
  config.filters = false
  # config.batch_actions = false

  scope :due_next_month_cad, default: true
  scope :due_next_month_usd

  batch_action :mark_as_paid do |selection|
    loan_payments = LoanPayment.find(selection)
    loan_payments.each(&:paid!)
    redirect_to admin_upcoming_loan_payments_path(scope: "due_next_month_#{loan_payments.first.currency}".downcase),
                notice: I18n.t('active_admin.upcoming_loan_payments.payment_set')
  end

  index do
    div class: 'hide loan-payment-report-total' do
      result = 0
      upcoming_loan_payments.each do |r|
        result += r.amount
      end
      number_to_currency(result, precision: 2)
    end

    selectable_column
    column :due_date, sortable: false
    column :loan do |item|
      link_to item.loan.name, admin_loan_path(item.loan.id)
    end
    column :borrower, sortable: false
    column :amount, sortable: false
    column :currency, sortable: false
  end
end
