# frozen_string_literal: true

ActiveAdmin.register SubInvestmentPayment do
  permit_params :id,
                :sub_investment_id,
                :admin_user_id,
                :due_date,
                :paid_date,
                :amount,
                :memo,
                :payment_kind,
                :check_no,
                :paid,
                :created_at,
                :updated_at,
                :start_date,
                :withdraw_id,
                :remark,
                :source_flag,
                :sub_investment_amount,
                :rate,
                :currency,
                :is_resend_statement

  menu false

  actions :all, except: [:new]

  config.sort_order = 'due_date_asc'

  scope :all_payments, default: true
  scope :pending
  scope :paid

  filter :payment_kind, label: 'Payment Type', as: :select, collection: Payment.payments_kinds_page
  filter :due_date
  filter :check_no

  controller do
    skip_before_action :verify_authenticity_token, only: [:make_payments]

    before_action :set_sub_investment_id, only: :index

    private

    def set_sub_investment_id
      # place in session because clear filter will clear any parameter
      # place in thread because model can access thread share variable
      session['sub_investment_id_for_payment'] = params[:sub_investment] if params[:sub_investment]
      Thread.current['sub_investment_id'] = session['sub_investment_id_for_payment']
      # for use in view
      @sub_investment = SubInvestment.find(Thread.current['sub_investment_id'])
    end
  end

  collection_action :make_payments, method: :post do
    payments = Payment.find(params[:collection_selection].split(','))
    payments.each do |payment|
      MakePaymentService.new(payment).call(params[:check_no] || 'PAID', params[:due_date])
    end
    SendPaymentEmailService.new.call(payments, params[:check_no]) if params[:email]
    redirect_to admin_sub_investment_payments_path, notice: I18n.t('active_admin.sub_investment_payments.payment_made')
  end

  batch_action :mark_as_paid do |selection|
    Payment.find(selection).each do |payment|
      MakePaymentService.new(payment).call('PAID')
    end
    redirect_to admin_sub_investment_payments_path, notice: I18n.t('active_admin.sub_investment_payments.payment_set')
  end

  batch_action :mark_as_pending do |selection|
    Payment.find(selection).each(&:pending!)
    redirect_to admin_sub_investment_payments_path, notice: I18n.t('active_admin.sub_investment_payments.payment_set')
  end

  index title: proc { "#{@sub_investment.name} Payments" } do
    selectable_column

    div class: 'hide sub-investments-payments-page'

    column 'Payee' do |item|
      item.admin_user&.name
    end
    column 'Sub Investment' do |item|
      investment = item.sub_investment
      link_to investment.name, admin_sub_investment_path(investment.id)
    end
    column 'Payment Type', &:payment_kind
    column :amount do |item|
      number_to_currency item.amount
    end
    column :currency do |item|
      item.sub_investment.currency
    end
    column :due_date
    column(:status) { |payment| status_tag(payment.status) }
    column :check_no
    actions
  end
end
