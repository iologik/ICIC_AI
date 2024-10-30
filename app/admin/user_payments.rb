# frozen_string_literal: true

ActiveAdmin.register UserPayment do
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

  scope :current_year_cad, default: true
  scope :current_year_usd
  scope :last_year_cad
  scope :last_year_usd
  scope :before_last_year_cad
  scope :before_last_year_usd
  scope :three_years_ago_cad
  scope :three_years_ago_usd
  scope :all_payments

  filter :paid_date
  # rubocop:disable Rails/UniqBeforePluck
  filter :source_flag, label: 'Investment Source', as: :check_boxes, collection: InvestmentSource.pluck(:name).uniq
  # rubocop:enable Rails/UniqBeforePluck
  filter :sub_investment, as: :select, collection: proc { AdminUser.find(params[:user] || session['admin_user_id_for_payment']).sub_investments }
  filter :payment_kind, label: 'Payment Type', as: :check_boxes, collection: Payment.payments_kinds_page
  filter :check_no
  filter :currency, as: :select, collection: %w(USD CAD)
  filter :paid, label: 'Paid status', as: :check_boxes, collection: [['PAID', true], ['UNPAID', false]]

  controller do
    before_action :non_admin_visit_own!, only: :index
    before_action :set_admin_user_id, only: :index

    def index
      super do |format|
        format.pdf do
          pdf_renderer = BuildPaymentsPDFService.new.call(@user_payments, is_user_payment: true)
          filename     = "#{@user_payments.last.due_date.strftime('%Y-%m-%d')} #{@admin_user.name}.pdf"
          send_data pdf_renderer.render, type: 'application/pdf', disposition: 'inline', filename: filename
          # send_data renders the pdf on the client side rather than saving it on the server filesystem.
          # Inline disposition renders it in the browser rather than making it a file download.
        end
        if params[:format] == 'csv'
          # send file to user
          send_data BuildPaymentsCsvService.new.call(@user_payments, is_user_payment: true), type: 'text/csv', disposition: 'inline'
          return
        end
      end
    end

    private

    def set_admin_user_id
      # place in session because clear filter will clear any parameter
      # place in thread because model can access thread share variable
      session['admin_user_id_for_payment'] = params[:user] if params[:user]
      Thread.current['admin_user_id'] = session['admin_user_id_for_payment']
      # for use in view
      @admin_user = AdminUser.find(Thread.current['admin_user_id'])
    end

    def non_admin_visit_own!
      return unless !current_admin_user.admin && params[:user] != current_admin_user.id.to_s

      redirect_to admin_sub_investor_path(id: current_admin_user.id)
    end
  end

  index title: proc { "#{@admin_user.name} Payments" } do
    div class: 'hide user-payment-total' do
      result = 0
      user_payments.each do |p|
        result += p.amount
      end
      number_to_currency result
    end

    selectable_column if current_admin_user.admin

    column 'Sub Investment' do |item|
      investment = item.sub_investment
      link_to investment.name, admin_sub_investment_path(investment.id)
    end
    column 'CUR' do |item|
      item.sub_investment.currency
    end
    column 'Investment Principal' do |item|
      number_to_currency(item.sub_investment_amount, precision: 2)
    end
    column 'Payment Type', &:payment_kind
    # column 'Payment Period' do |item|
    #  item.sub_investment.scheduled
    # end
    column '%' do |item|
      number_to_percentage(item.rate, precision: 2)
    end
    column :amount do |item|
      number_to_currency item.amount
    end
    column 'C No.', &:check_no
    column :due_date
    column :paid_date
    column(:status) { |payment| status_tag(payment.status) }
    actions
  end
end
