# frozen_string_literal: true

ActiveAdmin.register AdminUser, as: 'Sub Investor' do
  permit_params :email, :password, :password_confirmation, :remember_me,
                :first_name, :last_name, :home_phone, :work_phone, :mobile_phone,
                :address, :city, :province, :country, :postal_code, :admin,
                :rrsp, :rif, :lif, :lira, :company_name, :status, :pin

  config.sort_order = 'last_name_asc_and_first_name_asc'

  menu label: proc { current_admin_user.admin ? 'Sub-Investors' : 'Investments' }, priority: 5

  scope :order_by_name, default: true

  config.clear_action_items!

  actions :all

  controller do
    before_action :no_sub_investor_index, only: :index
    before_action :check_paid_payments, only: :destroy
    skip_before_action :verify_authenticity_token,
                       only: %i(generate_statement generate_accrued_retailed_report upload_signed_acknowledgment)
    before_action :set_default_status, only: [:index]

    def scoped_collection
      super.group(:id)
    end

    private

    def no_sub_investor_index
      redirect_to admin_sub_investor_path(id: current_admin_user.id) unless current_admin_user.admin?
    end

    def check_paid_payments
      return unless Payment.exists?(admin_user_id: params[:id], paid: true)

      redirect_to admin_sub_investor_path(id: params[:id]), alert: I18n.t('active_admin.admin_users.delete_failed')
    end

    def current_user
      current_admin_user
    end

    def set_default_status
      return if params['commit'].present?

      params['q'] = { 'status_in' => ['active'] }
    end
  end

  action_item :new, only: :index do
    link_to 'New Sub Investor', new_admin_sub_investor_path
  end

  action_item :edit, only: :info do
    link_to 'Edit', edit_admin_sub_investor_path(params[:id]) if can? :update, SubInvestment
  end

  action_item :info, only: :show do
    link_to 'Sub-Investor Info', info_admin_sub_investor_path(sub_investor)
  end

  action_item :invest, only: :show do
    link_to 'Invest', "/admin/sub_investments/new?user=#{sub_investor.id}" if can? :create, SubInvestment
  end

  action_item :generate_acknowledgment, only: :show, class: 'acknowledgment' do
    if can? :generate_risk_acknowledgment,
            SubInvestment
      link_to 'Generate Risk Acknowledgment',
              "/admin/sub_investors/#{sub_investor.id}/generate_risk_acknowledgment"
    end
  end

  action_item :download_acknowledgment, only: :show, class: 'acknowledgment' do
    if (can? :download_risk_acknowledgment,
             AdminUser) && sub_investor.risk_acknowledgment.attached?
      link_to 'Download Acknowledgment', sub_investor.risk_acknowledgment.service_url,
              target: '_blank', rel: 'noopener'
    end
  end

  action_item :upload_signed_acknowledgment, only: :show, class: 'acknowledgment' do
    if can? :upload_signed_acknowledgment,
            AdminUser
      link_to 'Upload Signed Acknowledgment', "/admin/sub_investors/#{sub_investor.id}/upload_signed_acknowledgment",
              id: 'upload-signed-acknowledgment'
    end
  end

  action_item :download_signed_acknowledgment, only: :show, class: 'acknowledgment' do
    if (can? :download_signed_risk_acknowledgment,
             AdminUser) && sub_investor.signed_risk_acknowledgment.attached?
      link_to 'Download Signed Acknowledgment', sub_investor.signed_risk_acknowledgment.service_url,
              target: '_blank', rel: 'noopener'
    end
  end

  action_item :sub_investor, only: :show do
    link_to "#{sub_investor.name}'s payments",
            "/admin/user_payments?user=#{sub_investor.id}&scope=#{UserPayment.first_scope(sub_investor.id)}"
  end

  action_item :statement, only: :show do
    link_to 'Statement / Report', '', class: 'sub-investor-statement'
  end

  action_item :invest, only: :show do
    link_to 'Accrued/Interest Reserve Report', '', class: 'sub-investor-retained-statement'
    # link_to "Accrued/Interest Reserve Report" , "/admin/sub_investors/#{sub_investor.id}/generate_accrued_retailed_report"
  end

  action_item :transaction_report, only: :show do
    min_date = sub_investor.sub_investments.pluck(:created_at).compact.min
    currency = sub_investor.sub_investments.pluck(:currency).uniq.join(', ')
    if min_date
      min_date = min_date.strftime('%Y-%m-%d')
      html_option = {
        :id => 'investor_transaction_report',
        'data-id' => sub_investor.id,
        'data-start-date' => min_date,
        'data-currency' => currency,
      }
      link_to 'Transaction Ledger', '#', html_option
    end
  end

  action_item :delete, only: :show do
    if can? :destroy,
            sub_investor
      link_to 'Delete', admin_sub_investor_path(id: sub_investor.id),
              data: { method: 'delete', confirm: 'Are you sure you want to delete this?' }
    end
  end

  member_action :generate_risk_acknowledgment, method: :get do
    AdminUser.find(params[:id]).build_risk_acknowledgment
    redirect_to admin_sub_investor_path(params[:id]), notice: I18n.t('active_admin.admin_users.risk_acknowledgment_built')
  end

  member_action :upload_signed_acknowledgment, method: :post do
    AdminUser.find(params[:id]).upload_signed_acknowledgment(params[:signed_acknowledgment])
    redirect_to admin_sub_investor_path(params[:id]), notice: I18n.t('active_admin.admin_users.signed_risk_acknowledgment_uploaded')
  end

  member_action :info, method: :get do
    @admin_user = AdminUser.find(params[:id])
  end

  # rubocop:disable Lint/RescueException
  member_action :generate_statement, method: :post do
    @admin_user = AdminUser.find(params[:id])
    sub_investments = if params[:sub_investment_id] == 'all'
                        @admin_user.sub_investments
                      else
                        [SubInvestment.find(params[:sub_investment_id])]
                      end

    pdf = BuildStatementService.new.call(sub_investments, params[:investment_source], params[:investment_status],
                                         params[:payment_kind], params[:date_from], params[:date_to])

    if params[:email] == 'true'
      filename = "#{@admin_user.name}'s investments"
      pdf.render_file "#{filename}.pdf"
      SubInvestorMailer.investments_email(@admin_user, filename).deliver
      File.delete("#{filename}.pdf")
    end

    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  rescue Exception
    render 'generate_statement_error'
  end

  member_action :generate_accrued_retailed_report, method: :post do
    @admin_user = AdminUser.find(params[:id])
    sub_investments = if params[:sub_investment_id] == 'all'
                        @admin_user.sub_investments
                      else
                        [SubInvestment.find(params[:sub_investment_id])]
                      end

    # check if any subinvestment's paid payments have nil paid date
    payments_with_error = []
    if params[:paid] == 'true'
      sub_investments.each do |s|
        payments = s.payments_with_no_paid_date
        payments_with_error += payments
      end
    end

    if payments_with_error.any?
      @payments = payments_with_error
      render 'payment_error'
      return
    end

    # build report if no issue
    pdf = BuildAccruedRetainedReportService.new.call(sub_investments, params, paid: params[:paid] == 'true')

    if params[:email] == 'true'
      filename = "#{@admin_user.name}'s investments"
      pdf.render_file "#{filename}.pdf"
      SubInvestorMailer.investments_email(@admin_user, filename).deliver
      File.delete("#{filename}.pdf")
    end

    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  rescue Exception
    render 'generate_accrued_retailed_report_error'
  end

  member_action :sub_investment_ids, method: :get do
    sub_investor = AdminUser.find(params[:id])
    render json: sub_investor.sub_investments.pluck(:id)
  end

  member_action :transaction_report, method: :get do
    subinvestor = AdminUser.find(params[:id])
    resp = BuildSubInvestorTransactionReportService.new.call(subinvestor, params[:date_from], params[:date_to],
                                                             params[:currency], params[:investment_source])
    if resp[:success]
      filename = "#{subinvestor.name}.transactionledger.#{Time.zone.today}.pdf"
      pdf      = resp[:file]
      send_data pdf.render, type: 'application/pdf', disposition: 'inline', filename: filename
    else
      @error_type     = resp[:error_type]
      @transactions   = resp[:transactions]
      @sub_investment = resp[:sub_investment]
      render 'transaction_error'
    end
  rescue Exception
    render 'transaction_report_error'
  end
  # rubocop:enable Lint/RescueException

  collection_action :change_password, method: :get do
    @admin_user = current_admin_user
  end

  collection_action :save_password, method: :put do
    @admin_user = current_admin_user
    if @admin_user.update(params[:admin_user])
      redirect_to admin_sub_investor_path(id: @admin_user.id)
    else
      render :change_password
    end
  end

  index title: 'Sub-Investors' do
    selectable_column
    id_column
    column 'Name', sortable: 'last_name' do |o|
      link_to o.name, admin_sub_investor_path(o)
    end
    column :company_name
    column 'Investment Amount(USD)' do |o|
      number_to_currency o.investment_amount_usd, precision: 2
    end

    column 'Investment Amount(CAD)' do |o|
      number_to_currency o.investment_amount_cad, precision: 2
    end
    #  column :phone do |o|
    #    "#{o.home_phone} #{o.work_phone} #{o.mobile_phone}"
    #  end
    actions
  end

  filter :last_name
  filter :first_name
  filter :status, as: :check_boxes, collection: %w(active archived)
  # rubocop:disable Rails/UniqBeforePluck
  filter :sub_investments_currency, as: :select, label: 'Currency', collection: proc { SubInvestment.pluck(:currency).uniq.compact }
  filter :sub_investments_sub_investment_source_id, as: :check_boxes, label: 'Investment Source', collection: proc { SubInvestment.pluck(:sub_investment_source_id).uniq.compact }
  # rubocop:enable Rails/UniqBeforePluck

  form do |f|
    if f.object.new_record?
      f.inputs do
        f.input :last_name
        f.input :first_name
        f.input :company_name
        f.input :email
        f.input :password, as: :string
        f.input :password_confirmation, as: :string
        f.input :status, as: :select, collection: %w(active archived)
      end
    else
      f.inputs 'Investor Info' do
        f.input :last_name
        f.input :first_name
        f.input :company_name
        f.input :email
        f.input :rrsp
        f.input :rif
        f.input :lif
        f.input :lira
        # f.input :image_url
        f.input :pin
        f.input :admin
      end

      f.inputs 'Sub Investor Phones' do
        f.input :home_phone
        f.input :work_phone
        f.input :mobile_phone
      end

      f.inputs 'Sub Investor Addresses' do
        f.input :address
        f.input :city
        f.input :province
        f.input :country, as: :string
        f.input :postal_code
        f.input :status, as: :select, collection: %w(active archived)
      end

      f.inputs 'Password', id: 'edit_sub_investor_password' do
        f.input :password
        f.input :password_confirmation
      end
    end
    f.actions
  end

  show do |user|
    div :class => 'hide sub-investor-id', 'data-id' => user.id
    # icic sub-investments
    sub_investments = user.sub_investments.eager_load(:interest_periods, :withdraws, :payments, :investment)

    user.sub_investments.find_each do |sub_investment|
      div :class => 'hide sub-investment-option', 'data-id' => sub_investment.id, 'data-name' => sub_investment.name,
          'data-start-date' => sub_investment.start_date, 'data-end-date' => sub_investment.end_date
    end

    panel('Investments', id: 'sub_investor_icic_investments') do
      # it is also okay to do it in the frontend
      if sub_investments.active.count.positive?
        div class: 'active-default'
      elsif sub_investments.archived.count.positive?
        div class: 'archived-default'
      elsif sub_investments.count.positive?
        div class: 'all-default'
      end

      InvestmentSource.reorder(:priority).each do |investment_source|
        div :class => 'investment-source', 'data-id' => investment_source.id, 'data-name' => investment_source.name
      end

      table_for sub_investments.order(name: :asc) do
        column 'name' do |item|
          state = (item.amount.zero? ? 'archived' : 'active')

          link_to item.name, "/admin/sub_investments/#{item.id}", 'data-currency' => item.currency, 'data-state' => state, 'data-investment-source' => item.investment.investment_source.id,
                                                                  'data-amount' => item.current_amount,
                                                                  'data-per-annum' => item.per_annum,
                                                                  'data-referrand-percent' => item.referrand_percent,
                                                                  'data-accrued-per-annum' => item.accrued_per_annum,
                                                                  'data-current-accrued' => item.current_accrued,
                                                                  'data-retained-per-annum' => item.retained_per_annum,
                                                                  'data-current-retained' => item.current_retained
        end
        column :account do |item|
          link_to item.account&.name, admin_account_path(item.account.id) if item.account
        end
        column :amount do |item|
          steps = item.current_amount_steps

          total_in = total_out = 0

          steps.each do |step|
            total_in += (step.in || 0)
            total_out += (step.out || 0)
          end

          number_to_currency(total_in - total_out, precision: 2).to_s
        end
        column :currency
        column 'Interest p.a' do |item|
          number_to_percentage item.per_annum, precision: 2
        end
        if current_admin_user.admin
          column 'AMF' do |item|
            number_to_percentage item.referrand_percent, precision: 2
          end
        end
        column 'Current Accrued' do |item|
          interest_period = item.interest_periods.order(:effect_date).last

          number_to_percentage(interest_period.accrued_per_annum,
                               precision: 2) + "  -  #{interest_period.effect_date}\n"
        end
        column :start_date
        column 'Investment Source' do |item|
          item.investment.investment_source.name
        end
      end
    end

    payments_list = [
      {
        collection: user.payments.due_next_month_cad.includes(sub_investment: :investment),
        panel_title: 'Upcoming Payments(CAD)',
        is_imor: false,
      },
      {
        collection: user.payments.due_next_month_usd.includes(sub_investment: :investment),
        panel_title: 'Upcoming Payments(USD)',
        is_imor: false,
      },
    ]

    payments_list.each do |payments|
      next unless payments[:collection].count.positive?

      panel(payments[:panel_title], class: 'upcoming-payments-panel') do
        total_amount = 0
        payments[:collection].each do |p|
          total_amount += p.amount
        end
        div class: 'hide upcoming-payment-total' do
          number_to_currency(total_amount, precision: 2)
        end

        table_for(payments[:collection], class: 'index_table index custom_sort_table') do
          column :sub_investment do |item|
            if item.sub_investment
              link_to item.sub_investment.name, admin_sub_investment_path(item.sub_investment.id),
                      data: { investment_source: item.sub_investment.investment.investment_source.id, amount: item.amount }
            end
          end
          column :account do |item|
            if item.sub_investment&.account
              link_to item.sub_investment.account&.name, admin_account_path(item.sub_investment.account.id),
                      data: { id: item.sub_investment.account.id, value: item.amount }
            end
          end
          column :amount do |item|
            number_to_currency item.amount
          end
          column :currency do |item|
            item.sub_investment&.currency
          end
          column :paid_date
          column :due_date
          column 'Payment Type', &:payment_kind
          column :memo
          column :investment_source do |item|
            item.sub_investment.investment.investment_source.name if item.sub_investment
          end
        end
      end
    end
  end

  sidebar('title', only: %i(new edit create update change_password save_password), id: 'blank_space_panel') {}
end
