# frozen_string_literal: true

ActiveAdmin.register Payment do
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

  csv do
    column :id
    column :sub_investor_name
    column :investment_name
    column :payment_kind
    column :amount
    column :currency
    column :due_date
    column :paid_date
    column(:status) { |payment| payment.paid ? 'Paid' : 'Pending' }
    column :memo
    column :check_no
    column :created_at
    column :updated_at
    column :start_date
    column :remark
    column :source_flag
    column :sub_investment_amount
    column :rate
    column(:investment_start_date) { |payment| payment.sub_investment.start_date }
  end

  config.per_page = 30

  controller do
    def scoped_collection
      super.includes :sub_investment, :admin_user
    end

    skip_before_action :verify_authenticity_token, only: %i(make_payments transfer_to make_single_payment)

    before_action :save_search_criteria, only: :index

    # rubocop:disable Metrics/AbcSize
    def index
      super do |format|
        format.pdf do
          q_id = SecureRandom.uuid
          # redis.set(q_id, Payment.ransack(params[:q]).result.pluck(:id).join(', '))
          redis.set(q_id, @payments.except(:limit, :offset).pluck(:id).join(', '))
          BuildPaymentsPDFWorker.perform_async(q_id, current_admin_user.email)
          # send_data BuildPayments.build(@payments).render, type: "application/pdf", disposition: "inline"
          # send_data renders the pdf on the client side rather than saving it on the server filesystem.
          # Inline disposition renders it in the browser rather than making it a file download.
          redirect_to request.referer, notice: I18n.t('active_admin.payments.payment_report_generation_progress')
        end
        format.csv do
          # send file to user
          send_data BuildPaymentsCsvService.new.call(@payments), type: 'text/csv', disposition: 'inline'
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    def update
      payment = Payment.find(params[:id])
      prev_paid_status = payment.paid
      super
      payment.reload
      next_paid_status = payment.paid

      paid_callback(payment, prev_paid_status, next_paid_status)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def paid_callback(payment, prev_paid_status, next_paid_status)
      pending_to_paid  = prev_paid_status == false && next_paid_status == true
      paid_to_pending  = prev_paid_status == true && next_paid_status == false

      payment_kind     = payment.payment_kind
      sub_investment   = payment.sub_investment
      withdraw         = payment.withdraw
      paid             = payment.paid

      if payment.payment_kind == Payment::Type_Principal
        NotifyPrincipalPaybackService.new.call(payment) if pending_to_paid
        UpdateSubInvestmentPaymentWorker.perform_async(sub_investment_id) if prev_paid_status && next_paid_status
      end

      if withdraw
        UpdateWithdrawFromPaymentService.new.call(payment)
        withdraw.update(paid: paid) if paid != withdraw.paid
      end

      return unless payment_kind.in? [Payment::Type_Withdraw, Payment::Type_Transfer, Payment::Type_Principal]

      sub_investment.affect_investment(payment.amount) if payment.pay_payment?(pending_to_paid)
      sub_investment.affect_investment(0 - payment.amount) if payment.unpaid_payment?(paid_to_pending)
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    def destroy
      payment = Payment.find(params[:id])
      if payment.withdraw
        redirect_to admin_payment_path(payment.id), alert: I18n.t('active_admin.payments.unable_to_delete_withdraw_payment')
      else
        payment.destroy
        redirect_to admin_sub_investment_path(payment.sub_investment_id), notice: I18n.t('active_admin.payments.payment_deleted')
      end
    end

    private

    def save_search_criteria
      session[:payment_index_url] = request.original_url
    end
  end

  menu priority: 4

  config.sort_order = 'sub_investor_name_asc'

  scope :due_next_month_cad
  scope :due_next_month_usd
  scope :all_payments, default: true
  scope :pending
  scope :paid
  scope :rrsp

  filter :due_date
  filter :paid_date
  # rubocop:disable Rails/UniqBeforePluck
  filter :source_flag, label: 'Investment Source', as: :check_boxes, collection: InvestmentSource.pluck(:name).uniq # This fix would broke active admin routing
  # rubocop:enable Rails/UniqBeforePluck
  filter :admin_user, label: 'Sub Investor', as: :select, collection: AdminUser.order_by_name
  filter :sub_investment, as: :select, collection: SubInvestment.order_name
  filter :payment_kind, label: 'Payment Type', as: :check_boxes, collection: Payment.payments_kinds_page
  filter :check_no
  filter :currency, as: :select, collection: %w(USD CAD)
  filter :paid, label: 'Paid status', as: :check_boxes, collection: [['PAID', true], ['UNPAID', false]]

  batch_action :destroy, false # disable here, but added as the last batch action

  config.clear_action_items!
  config.batch_actions = true

  action_item :resend_statement, only: :show do
    link_to 'Resend Statement', "/admin/payments/#{params[:id]}/resend_statement"
  end

  action_item :make_payment, only: :show do
    payment = Payment.find(params[:id])

    link_to 'Make Payment', '#', class: 'make-single-payment' unless payment.paid
  end

  action_item :edit, only: :show do
    link_to 'Edit Payment', edit_admin_payment_path(params[:id])
  end

  action_item :delete, only: :show do
    unless payment.withdraw
      link_to 'Delete Payment', admin_payment_path(params[:id]),
              data: { confirm: 'Are you sure you want to delete this?', method: 'delete' }
    end
  end

  action_item :new, only: :index do
    link_to 'New Payment', new_admin_payment_path
  end

  collection_action :t5report, method: :get do
    @year = params['year'] || Time.zone.today.year
    @reports = T5Report.payments_by_year(@year, params[:investment_source_id], params[:payment_type])
    respond_to do |format|
      format.pdf do
        send_data BuildT5ReportService.new.call(@reports).render, type: 'application/pdf', disposition: ' inline'
      end
      format.csv do
        # send file to user
        send_data BuildT5ReportCsvService.new.call(@reports, params[:exchange_rate].to_f), type: 'text/csv',
                                                                                           disposition: 'inline'
      end
    end
  end

  collection_action :export, method: :get do
    render text: Payment.export
  end

  collection_action :send_mail, method: :post do
    payments = Payment.find(params[:collection_selection].split(','))
    SendPaymentEmailService.new.call(payments)
    render nothing: true
  end

  collection_action :make_payments, method: :post do
    payments = Payment.find(params[:collection_selection].split(','))
    principal_payments = []
    other_payments = []
    payments.each do |payment|
      MakePaymentService.new(payment).call(params[:check_no] || 'PAID', params[:due_date], params[:paid_date])
      if payment.payment_kind == Payment::Type_Principal
        principal_payments.push(payment)
      else
        other_payments.push(payment)
      end
    end

    SendPaymentEmailService.new.call(other_payments, params[:check_no]) if params[:email] && other_payments.any?

    principal_payments.each do |principal_payment|
      NotifyPrincipalPaybackService.new.call(principal_payment)
    end

    redirect_to session[:payment_index_url], notice: I18n.t('active_admin.payments.payment_made')
  end

  batch_action :mark_as_paid do |selection|
    Payment.find(selection).each do |payment|
      MakePaymentService.new(payment).call('PAID', nil, Time.zone.today.to_s)
    end
    redirect_to session[:payment_index_url], notice: I18n.t('active_admin.payments.payment_set')
  end

  batch_action :mark_as_pending do |selection|
    Payment.find(selection).each(&:pending!)
    redirect_to session[:payment_index_url], notice: I18n.t('active_admin.payments.payment_set')
  end

  # customize delete action
  batch_action :destroy do |selection|
    Payment.find(selection).each(&:destroy)
    redirect_to session[:payment_index_url], notice: I18n.t('active_admin.payments.payment_deleted')
  end

  action_item :payments_report, only: :index do
    link_to 'Payments Report', admin_payment_reports_path
  end

  member_action :transfer_to, method: :post do
    begin
      payment = Payment.find(params[:id])

      transfer_amount = payment.amount
      transfer_currency = payment.currency

      old_sub_investment = payment.sub_investment
      new_sub_investment = SubInvestment.find(params[:transfer_to_id])

      exchange_rate = params[:exchange_rate].to_f || 1.00

      new_sub_investment.amount += payment.amount * exchange_rate
      new_sub_investment.save

      MakePaymentService.new(payment).call unless new_sub_investment.errors.any?
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_payments_path, alert: e.message
      return
    end

    unless new_sub_investment.errors.any?
      withdraw1 = Withdraw.new(
        amount: payment.amount,
        admin_user: payment.admin_user,
        sub_investment: old_sub_investment,
        transfer_to: new_sub_investment,
        due_date: old_sub_investment.end_date,
        is_transfer: false
      )
      withdraw1.save

      withdraw2 = Withdraw.new(
        type: 'Increase',
        amount: payment.amount,
        admin_user: payment.admin_user,
        sub_investment: new_sub_investment,
        transfer_from: old_sub_investment,
        due_date: new_sub_investment.end_date,
        is_transfer: true
      )
      withdraw2.save

      if params[:email_subinvestor] == 'true'
        PaymentsMailer.transfer(payment.admin_user, old_sub_investment, new_sub_investment, transfer_amount,
                                transfer_currency, payment.payment_kind).deliver
      end
    end

    redirect_to admin_payments_path, notice: I18n.t('active_admin.payments.transfer_built')
  end

  member_action :make_single_payment, method: :post do
    payment = Payment.find(params[:id])
    MakePaymentService.new(payment).call(params[:check_no] || 'PAID', params[:due_date], params[:paid_date])
    SendPaymentEmailService.new.call([payment], params[:check_no]) if params[:email] && payment.payment_kind != Payment::Type_Principal

    NotifyPrincipalPaybackService.new.call(payment) if payment.payment_kind == Payment::Type_Principal

    redirect_to "/admin/payments/#{payment.id}"
  end

  member_action :resend_statement, method: :get do
    @payment = Payment.find(params[:id])
    if @payment.paid_date.nil?
      @notification = 'The payment you specified does not have a paid date entered. Please correct the issue and try again'
      render 'error'
      return
    end

    res = if @payment.payment_kind == Payment::Type_Withdraw
            SendWithdrawEmailService.new.call(@payment.withdraw)
          else
            SendPaymentEmailService.new.call([@payment])
          end

    if res
      redirect_to "/admin/payments/#{params[:id]}", flash: { success: 'Resent statement successfully' }
    else
      @notification = 'The payment you specified has invalid character in pdf file name'
      render 'error'
    end
  end

  show do
    attributes_table do
      row 'payment_id', class: 'hide payment-id', &:id
      row 'Sub Investor' do
        payment.admin_user
      end
      row :amount do |a|
        number_to_currency(a.amount, precision: 2)
      end
      row :currency, class: 'hide payment-currency' do |a|
        a.sub_investment.currency
      end
      row :due_date
      row :paid_date
      row :sub_investment
      row :check_no
      row :paid
      row :memo
      row 'Payment Type', &:payment_kind
    end
  end

  index do
    div class: 'hide payments-page'

    exchange_rate_usd_cad = Investment.latest_rate('usd')
    exchange_rate_cad_usd = Investment.latest_rate('cad')

    payment_ids = payments.pluck(:id)
    tpayments = Payment.where(id: payment_ids)
    total_amount = tpayments.sum(:amount)

    total_amount_cad = tpayments.where(currency: 'CAD').sum(:amount)
    total_amount_usd = tpayments.where(currency: 'USD').sum(:amount)

    total_amount_cad_all = Payment.ransack(params[:q]).result.where(currency: 'CAD').sum(:amount)
    total_amount_usd_all = Payment.ransack(params[:q]).result.where(currency: 'USD').sum(:amount)

    div class: 'hide total_payment_amount' do
      number_to_currency total_amount
    end

    div class: 'hide total_payment_amount_cad' do
      number_to_currency total_amount_cad
    end

    div class: 'hide total_payment_amount_usd' do
      number_to_currency total_amount_usd
    end

    div class: 'hide total_payment_amount_cad_all' do
      number_to_currency total_amount_cad_all
    end

    div class: 'hide total_payment_amount_usd_all' do
      number_to_currency total_amount_usd_all
    end

    selectable_column

    column 'admin_user_id', class: 'hide admin_user_id', &:admin_user_id
    column :sub_investor_name, label: 'Sub Investor', &:sub_investor_name
    column :investment_name, label: 'Investment' do |item|
      if item.sub_investment
        link_to item.sub_investment.investment.name, admin_investment_path(item.sub_investment.investment_id)
      else
        ''
      end
    end
    column 'Payment Type', &:payment_kind
    column :amount do |item|
      number_to_currency(item.amount, precision: 2)
    end
    column :currency do |item|
      item.sub_investment&.currency
    end
    column :due_date
    column :paid_date
    column(:status) { |payment| status_tag(payment.status) }
    column :check_no
    # actions

    column do |p|
      div style: 'display:inline' do
        link_data = {
          payment_id: p.id,
          currency: p.currency,
          exchange_rate_usd_cad: exchange_rate_usd_cad,
          exchange_rate_cad_usd: exchange_rate_cad_usd,
          url: new_admin_payment_path(user: current_admin_user, transfer_from: p),
        }
        link_to 'Transfer', '#', class: 'transfer_payment', data: link_data
      end
      div style: 'display:inline' do
        link_to 'View', admin_payment_path(p)
      end
      div style: 'display:inline' do
        link_to 'Edit', edit_admin_payment_path(p)
      end
      div style: 'display:inline' do
        unless p.withdraw
          link_to 'Delete', admin_payment_path(p.id),
                  data: { method: 'delete', confirm: 'Are you sure?' }
        end
      end

      # div style: 'display:none' do
      #   if p.admin_user
      #     sub_invests = p.admin_user.sub_investments.to_a
      #     sub_investment = p.sub_investment
      #     sub_invests.delete_if { |s| s == sub_investment }
      #     sub_invests.sort { |x,y| x.investment.name <=> y.investment.name }.each do |sub_invest|
      #       account = sub_invest.account
      #       div class: 'hide other-sub-investment', "data-payment-id" => p.id, "data-id" => sub_invest.id, "data-name" => "#{sub_invest.investment.name} #{account&.name if account} #{sub_invest.currency}", "data-currency" => sub_invest.currency do end
      #     end
      #   end
      # end
    end
  end

  # add this form is because is
  # we do not use the default date format
  form do |f|
    min_date_on_all_records = [
      Payment.reorder(:due_date).first.due_date,
      Payment.reorder(:paid_date).first.paid_date,
      SubInvestment.order(:created_at).first.created_at,
      Investment.order(:created_at).first.created_at,
    ].min
    f.inputs do
      f.input :admin_user, label: 'Sub Investor', as: :select, collection: AdminUser.page_select
      f.input :sub_investment_id, as: :select, collection: SubInvestment.page_select
      f.input :currency, as: :select, collection: %w(CAD USD)
      f.input :due_date, order: %i(year month day), use_two_digit_numbers: true
      f.input :paid_date, order: %i(year month day), use_two_digit_numbers: true,
                          start_year: min_date_on_all_records.year
      if f.object.paid
        f.input :amount, input_html: { disabled: true, class: 'label-input' }
      else
        f.input :amount
      end
      f.input :memo
      f.input :payment_kind, as: :select, collection: Payment.payments_kinds_page, label: 'Payment Type'
      f.input :check_no
      f.input :paid
    end

    f.actions
  end

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
