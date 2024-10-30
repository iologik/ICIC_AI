# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety
ActiveAdmin.register SubInvestment do
  form partial: 'form'

  actions :all, except: [:destroy]

  config.sort_order = 'name_asc_and_created_at_asc'
  config.per_page = 30

  # filter :amount
  filter :admin_user, label: 'Investor', collection: AdminUser.order(:last_name)

  # rubocop:disable Rails/UniqBeforePluck
  filter :id, label: 'Sub Investment', as: :select, collection: SubInvestment.pluck(:name, :id).uniq
  filter :sub_investment_kind_id, label: 'Investment Kind', as: :select,
                                  collection: InvestmentKind.pluck(:name).uniq
  filter :sub_investment_source_id, label: 'Investment Source', as: :check_boxes,
                                    collection: InvestmentSource.pluck(:name).uniq
  filter :investment_status, as: :check_boxes, collection: InvestmentStatus.pluck(:name, :id).uniq
  # rubocop:enable Rails/UniqBeforePluck
  filter :currency, as: :select, collection: %w(CAD USD)

  # permit_params :admin_user_id,
  #               :investment_id,
  #               :scheduled,:months,
  #               :amount,
  #               :ori_amount,
  #               :currency,
  #               :per_annum,
  #               :accrued_per_annum,:start_date,:referrand_user_id,:referrand_percent,
  #               :referrand_one_time_amount,:referrand_amount,:referrand_scheduled,:investment_status_id,:description,:private_note,
  #               :referrand_one_time_date,
  #               :account_id,
  #               :transfer_from_id,
  #               :remote_agreement_url,
  #               :exchange_rate,
  #               interest_periods_attributes: [:effect_date, :per_annum, :accrued_per_annum]

  csv do
    column :id
    column :scheduled
    column(:start_date, &:start_date) # start_date is not field, it's method
    column :months
    column :amount
    column(:interest) { |sub_investment| "#{sub_investment.interest_periods.last.per_annum}%" }
    column :currency
    column(:length, &:months)
    column :updated_at
    column(:referrand_user, &:referrand_user_id)
    column :referrand_percent
    column :referrand_one_time_amount
    column :referrand_amount
    column :referrand_scheduled
    column :ori_amount
    column :description
    column :referrand_one_time_date
    column :private_note
    column :remote_agreement_url
    column :exchange_rate
    column :name
    column :signed_agreement_url
    column :memo
    column :initial_description
    column(:sub_investment_source, &:sub_investment_source_id)
    column(:sub_investment_kind, &:sub_investment_kind_id)
    column :is_notify_investor
    column :archive_date
    column :currency
    column(:interest1_date) { |sub_investment| sub_investment.interest_date(0) }
    column(:interest1_month_year) { |sub_investment| sub_investment.interest_month_year(0) }
    column(:interest1_accrued) { |sub_investment| sub_investment.interest_accrued(0) }
    column(:interest2_date) { |sub_investment| sub_investment.interest_date(1) }
    column(:interest2_month_year) { |sub_investment| sub_investment.interest_month_year(1) }
    column(:interest2_accrued) { |sub_investment| sub_investment.interest_accrued(1) }
    column(:interest3_date) { |sub_investment| sub_investment.interest_date(2) }
    column(:interest3_month_year) { |sub_investment| sub_investment.interest_month_year(2) }
    column(:interest3_accrued) { |sub_investment| sub_investment.interest_accrued(2) }
    column(:interest4_date) { |sub_investment| sub_investment.interest_date(3) }
    column(:interest4_month_year) { |sub_investment| sub_investment.interest_month_year(3) }
    column(:interest4_accrued) { |sub_investment| sub_investment.interest_accrued(3) }
    column(:interest5_date) { |sub_investment| sub_investment.interest_date(4) }
    column(:interest5_month_year) { |sub_investment| sub_investment.interest_month_year(4) }
    column(:interest5_accrued) { |sub_investment| sub_investment.interest_accrued(4) }
  end

  controller do
    skip_before_action :verify_authenticity_token,
                       only: %i(payment_batch_action update transfer_to charge_fee upload_signed_agreement
                                balance_report)
    before_action :set_current_user

    before_action only: [:index] do
      params['q'] = { investment_status_id_in: [InvestmentStatus.find_by(name: 'Active').id] } if !params[:q] || params[:q][:investment_status_id_in].blank?
    end

    before_action only: [:update] do
      @sub_investment = SubInvestment.find(params[:id])
    end

    def set_current_user
      @current_user = current_admin_user
    end

    # rubocop:disable Metrics/AbcSize
    def create
      params.permit!
      @sub_investment = SubInvestment.new(params[:sub_investment])
      if @sub_investment.save
        UpdateSubInvestmentAmountStatsService.new(@sub_investment.id).call
        UpdateSubInvestmentPaymentService.new(@sub_investment.id).call
        # send email to admin with documentation
        @sub_investment.notify
        redirect_to admin_sub_investment_path(@sub_investment)
      else
        redirect_to new_admin_sub_investment_path, flash: { error: @sub_investment.errors.messages.flatten.join(' - ') }
      end
    end

    def update
      params.permit!
      # @sub_investment = SubInvestment.new(params[:sub_investment])
      if @sub_investment.update(params[:sub_investment])
        UpdateSubInvestmentAmountStatsService.new(@sub_investment.id).call
        UpdateSubInvestmentPaymentService.new(@sub_investment.id).call
        redirect_to admin_sub_investment_path(@sub_investment)
      else
        redirect_to new_admin_sub_investment_path, flash: { error: @sub_investment.errors.messages.flatten.join(' - ') }
      end
    end

    def new
      # the user/investment/transfer_from are not always exist, but this is not a problem
      @sub_investment = SubInvestment.new(admin_user_id: params[:user], investment_id: params[:investment],
                                          transfer_from_id: params[:transfer_from])
      @sub_investment.admin_user = SubInvestment.find(params[:transfer_from]).admin_user if params[:transfer_from].present?
      # set investment if there is not
      @sub_investment.investment = Investment.first unless @sub_investment.investment
    end
    # rubocop:enable Metrics/AbcSize

    def current_user
      current_admin_user
    end

    def index
      super do |format|
        format.pdf { render(pdf: 'subinvestments.pdf') }
      end
    end
  end

  action_item :all, only: :show do
    link_to 'All payments', "/admin/sub_investment_payments?sub_investment=#{sub_investment.id}" if can? :read,
                                                                                                         SubInvestmentPayment
  end

  action_item :transfer, only: :show do
    if can? :create, SubInvestment
      link_to 'Transfer', '#', id: 'transfer_sub_investment',
                               data: { url: new_admin_sub_investment_path(user: current_admin_user.id, transfer_from: sub_investment.id) }
    end
  end

  action_item :generate, only: :show do
    if can? :generate_agreement,
            SubInvestment
      link_to 'Generate Sub-agreement',
              "/admin/sub_investments/#{sub_investment.id}/generate_agreement"
    end
  end

  action_item :add, only: :show do
    link_to 'Add Task', new_admin_task_path(sub_investment: sub_investment.id) if can? :create, Task
  end

  action_item :transaction_report, only: :show do
    link_to 'Transaction Ledger', '#',
            { :id => 'transaction_report', 'data-id' => sub_investment.id, 'data-start-date' => sub_investment.created_at.strftime('%Y-%m-%d') }
  end

  action_item :delete, only: :show do
    if can? :destroy,
            SubInvestment
      link_to 'Delete', "/admin/sub_investments/#{sub_investment.id}/destroy_self", method: :delete,
                                                                                    data: { confirm: 'Are you sure?' }
    end
  end

  action_item :generate, only: :show do
    if can? :adjust_payments,
            SubInvestment
      link_to 'Generate Payments', "/admin/sub_investments/#{sub_investment.id}/adjust_payments",
              style: 'display:none;'
    end
  end

  action_item :charge_fee, only: :show do
    if current_admin_user.admin?
      link_to 'Charge Fee', '#', id: 'charge_fee',
                                 data: { url: "/admin/sub_investments/#{sub_investment.id}/charge_fee" }
    end
  end

  action_item :refresh, only: :show do
    link_to 'Refresh', "/admin/sub_investments/#{sub_investment.id}/refresh" if current_admin_user.admin?
  end

  member_action :charge_fee, method: :post do
    sub_investment = SubInvestment.find(params[:id])

    due_date = Date.parse(params['due_date'])
    sub_investment.charge_fee(params['amount'], due_date, params['email_subinvestor'])

    redirect_to "/admin/sub_investments/#{sub_investment.id}"
  end

  member_action :adjust_payments, method: :get do
    UpdateSubInvestmentPaymentWorker.perform_async(params[:id])
    redirect_to "/admin/sub_investments/#{params[:id]}"
  end

  member_action :destroy_self, method: :delete do
    invest = SubInvestment.find(params[:id])
    if current_admin_user.admin? && invest
      DestroySubInvestmentService.new(invest.id).call
      redirect_to admin_investment_path(invest.investment.id)
    end
  end

  member_action :payment_batch_action, method: :post do
    selection = params[:collection_selection]
    payments = Payment.find(selection.split(','))
    case params[:batch_action]
    when 'destroy'
      payments.each(&:destroy)
    when 'mark_as_paid'
      payments.each do |payment|
        MakePaymentService.new(payment).call(params[:check_no] || 'PAID', params[:due_date], params[:paid_date])
      end
    when 'mark_as_pending'
      payments.each(&:pending!)
    when 'make_payment'
      payments.each do |payment|
        MakePaymentService.new(payment).call(params[:check_no] || 'PAID', params[:due_date], params[:paid_date])
      end
      SendPaymentEmailService.new.call(payments, params[:check_no]) if params[:email]
    end

    redirect_to admin_sub_investment_path(params[:id]), notice: I18n.t('active_admin.sub_investments.payment_set')
  end

  member_action :delete_accrued_payment, method: :delete do
    SubInvestment.find(params[:id]).sub_accrued_payments.find(params[:accrued_payment_id]).destroy
    redirect_to admin_sub_investment_path(params[:id]), notice: I18n.t('active_admin.sub_investments.accrued_payment_delete')
  end

  member_action :delete_retained_payment, method: :delete do
    SubInvestment.find(params[:id]).sub_retained_payments.find(params[:retained_payment_id]).destroy
    redirect_to admin_sub_investment_path(params[:id]), notice: I18n.t('active_admin.sub_investments.interest_reserve_payment_delete')
  end

  member_action :generate_agreement, method: :get do
    SubInvestment.find(params[:id]).build_agreement
    redirect_to admin_sub_investment_path(params[:id]), notice: I18n.t('active_admin.sub_investments.agreement_built')
  end

  member_action :transaction_report, method: :get do
    subinvestment = SubInvestment.find(params[:id])
    resp = BuildSubInvestmentTransactionReportService.new.call(subinvestment, params[:date_from], params[:date_to])

    if resp[:success]
      pdf = resp[:file]
      filename = "#{subinvestment.name}.transactionledger.#{Time.zone.today}.pdf"
      send_data pdf.render, type: 'application/pdf', disposition: 'inline', filename: filename
    else
      @error_type     = resp[:error_type]
      @transactions   = resp[:transactions]
      @sub_investment = resp[:sub_investment]
      render 'transaction_error'
    end
  end

  member_action :upload_signed_agreement, method: :post do
    SubInvestment.find(params[:id]).upload_signed_agreement(params[:signed_agreement])
    redirect_to admin_sub_investment_path(params[:id]), notice: I18n.t('active_admin.sub_investments.signed_agreement_uploaded')
  end

  member_action :transfer_to, method: :post do
    date = Date.parse params['transfer_date']
    sub_investment = SubInvestment.find(params[:id])
    # will transfer automatically
    begin
      sub_distribution_param = {
        sub_investment_id: sub_investment.id,
        amount: params[:amount].to_f,
        date: date,
        admin_user_id: sub_investment.admin_user_id,
        transfer_to_id: params[:transfer_to_id],
        sub_distribution_type: 'Transfer',
        is_notify_investor: params[:is_notify_investor] == 'true',
        check_no: params[:check_no],
        origin_amount: sub_investment.amount,
        target_amount: SubInvestment.find(params[:transfer_to_id]).amount,
      }

      SubDistribution.create!(sub_distribution_param)
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_sub_investment_path(params[:id]), notice: e.message
      return
    end
    redirect_to admin_sub_investment_path(params[:transfer_to_id]), notice: I18n.t('active_admin.sub_investments.transfer_built')
  end

  member_action :accrued_notify, method: :post do
    sub_investment = SubInvestment.find(params[:id])
    pdf = BuildAccruedNotificationReportService.new.call([sub_investment], Date.parse(params[:date]))
    filename = "#{sub_investment.admin_user.name}'s current accrued on #{params[:date]}".tr('/', '-')
    pdf.render_file "#{filename}.pdf"
    AccruedMailer.notify(sub_investment, params[:date], filename).deliver
    File.delete("#{filename}.pdf")

    head 204
  end

  member_action :refresh, method: :get do
    UpdateSubInvestmentStatsWorker.perform_async(params[:id])
    redirect_to admin_sub_investment_path(params[:id]), notice: I18n.t('active_admin.sub_investments.refresh_started')
  end

  collection_action :batch_accrued_notify, method: :post do
    sub_investments = SubInvestment.find(params[:sub_investment_ids])
    pdf = BuildAccruedNotificationReportService.new.call(sub_investments, Date.parse(params[:date]))
    filename = "#{sub_investments.first.admin_user.name}'s current accrued on #{params[:date]}".tr('/', '-')
    pdf.render_file "#{filename}.pdf"

    grouped_sub_investments = sub_investments.group_by(&:admin_user_id)
    grouped_sub_investments.each do |_idx, grouped_sub_investment|
      AccruedMailer.batch_notify(grouped_sub_investment, params[:date], filename).deliver
    end
    File.delete("#{filename}.pdf")
    head 204
  end

  member_action :retained_notify, method: :post do
    RetainedMailer.notify(SubInvestment.find(params[:id]), params[:date]).deliver
    head 204
  end

  collection_action :batch_retained_notify, method: :post do
    sub_investments = SubInvestment.find(params[:sub_investment_ids])
    grouped_sub_investments = sub_investments.group_by(&:admin_user_id)
    grouped_sub_investments.each do |_idx, grouped_sub_investment|
      RetainedMailer.batch_notify(grouped_sub_investment, params[:date]).deliver
    end
    head 204
  end

  member_action :send_agreement_email, method: :get do
    AgreementMailer.agreement_email(SubInvestment.find(params[:id])).deliver
    redirect_to admin_sub_investment_path(params[:id]), notice: I18n.t('active_admin.sub_investments.agreement_email_sent')
  end

  collection_action :sub_investment_ids, method: :get do
    admin_user_id = params[:admin_user_id]
    admin_user = AdminUser.find(admin_user_id)
    render json: {
      is_admin: admin_user.admin?,
      sub_investment_ids: admin_user.sub_investments.pluck(:id),
    }
  end

  index do
    column :id
    column :name do |item|
      link_to item.name, "/admin/sub_investments/#{item.id}" unless item.admin_user.nil?
    end
    column :account do |item|
      link_to item.account&.name, admin_account_path(item.account.id) if item.account
    end
    column :amount do |item|
      div class: 'amount' do
        link_to number_to_currency(item.amount, precision: 2), "/admin/sub_investments/#{item.id}"
      end
    end
    column :currency
    column 'Exchange Amount' do |item|
      if item.currency.casecmp('CAD').zero?
        nil
      else
        number_to_currency(item.amount * Investment.latest_rate, precision: 2)
      end
    end
    column :scheduled
    column :months
    column :interest do |item|
      number_to_percentage item.interest, precision: 2
    end
    column :accrued do |item|
      number_to_percentage item.accrued, precision: 2
    end
    column 'Interest Reserve', :retained do |item|
      number_to_percentage item.retained, precision: 2
    end
    column :status
    column :start_date
    # actions
    div :id => 'current-user-investments', :class => 'hide',
        'data-ids' => current_user.admin? ? Investment.pluck('id').join(',') : current_user.sub_investments.pluck('investment_id').join(',')
    div :id => 'current-users', :class => 'hide',
        'data-ids' => current_user.admin? ? AdminUser.pluck('id').join(',') : current_user.id.to_s
  end

  show do
    div :id => 'current_sub_investment_id', :class => 'hide', 'data-id' => sub_investment.id

    sub_invests = sub_investment.admin_user.sub_investments.to_a
    sub_invests.delete_if { |s| s == sub_investment }
    sub_invests.sort { |x, y| x.investment.name <=> y.investment.name }.each do |sub_invest|
      if sub_investment.start_date < sub_invest.start_date
        start1 = sub_investment
        start2 = sub_invest
      else
        start1 = sub_invest
        start2 = sub_investment
      end

      next unless start1.end_date >= start2.start_date

      div_class = 'hide other-sub-investment'
      name      = "#{sub_invest.investment.name} #{sub_invest.account&.name} #{sub_invest.currency}"
      div :class => div_class, 'data-id' => sub_invest.id, 'data-name' => name, 'data-account-type' => sub_invest.account&.name, 'data-end-date' => sub_invest.end_date
    end
    div :id => 'max_sub_investment_amount', :class => 'hide', 'data-value' => sub_investment.amount
    div :id => 'last_transfer_date', :class => 'hide', 'data-value' => sub_investment.end_date
    div :id => 'start_transfer_date', :class => 'hide', 'data-value' => sub_investment.start_date
    div :id => 'default_charge_fee_amount', :class => 'hide', 'data-value' => sub_investment.investment.fee_amount

    columns do
      column do
        attributes_table do
          # row :id
          row :transfer_from if sub_investment.transfer_from
          row 'Name' do |item|
            link_to item.admin_user.name, admin_sub_investor_path(id: item.admin_user.id)
          end
          row :investment
          row :account if sub_investment.account
          if can? :increase, SubInvestment

            row 'current amount' do |item|
              "#{number_to_currency(item.amount,
                                    precision: 2)} #{item.currency}  #{link_to 'Increase',
                                                                               new_admin_increase_path(sub_investment_id: sub_investment.id)} / #{link_to 'Withdraw',
                                                                                                                                                          new_admin_withdraw_path(sub_investment_id: sub_investment.id)}".html_safe
            end
          else
            row 'current amount' do |item|
              "#{number_to_currency(item.amount, precision: 2)} #{item.currency}"
            end
          end
          # row :ori_amount do | item|
          #  "#{number_to_currency(item.ori_amount, :precision => 2)} #{item.currency}"
          # end
          row :months
          row :memo
          row :scheduled
          row :exchange_rate if (sub_investment.currency != sub_investment.investment.currency) && sub_investment.exchange_rate
          row :status
          row 'agreement file' do |item|
            "#{link_to 'Click to download', item.remote_agreement.service_url if (can? :remote_agreement,
                                                                                       SubInvestment) && item.remote_agreement.attached?} #{if can? :adjust_payments,
                                                                                                                                                    SubInvestment
                                                                                                                                              link_to ' / Click to send email',
                                                                                                                                                      "/admin/sub_investments/#{sub_investment.id}/send_agreement_email"
                                                                                                                                            end}".html_safe
          end
          row 'signed agreement' do |item|
            "#{link_to('Click to upload', '', id: 'upload-signed-agreement') if can? :upload_sign_agreement,
                                                                                     SubInvestment}
            #{if item.signed_agreement.attached?
                link_to ' / Click for signed agreement',
                        item.signed_agreement.service_url
              end}".html_safe
          end
        end

        panel('Interest Periods', class: 'sub-investment-interest-periods') do
          table_for(sub_investment.interest_periods) do
            column :effect_date
            column 'Interest P.A.' do |item|
              number_to_percentage item.per_annum, precision: 2
            end
          end
        end

        # if sub_investment.current_accrued > 0
        div do
          panel('Current Accrued', class: 'sub-investment-per-annum-panel accrued-amount') do
            if sub_investment.current_accrued_amount.zero?
              number_to_currency 0, precision: 2
            else
              number_to_currency sub_investment.current_accrued_amount, precision: 2
            end
          end

          panel('Current Accrued', class: 'sub-investment-per-annum-panel accrued-percentage') do
            accrued_periods = sub_investment.interest_periods
            if accrued_periods.any?
              current_accrued = ''

              accrued_periods.each_cons(2) do |p|
                date_range = "#{p[0].effect_date} to #{p[1].effect_date}"
                current_accrued += number_to_percentage(p[0].accrued_per_annum,
                                                        precision: 2) + "  -  #{date_range}\n"
              end

              last_element = accrued_periods.last
              date_range = "#{last_element.effect_date} to current"
              current_accrued += number_to_percentage(last_element.accrued_per_annum,
                                                      precision: 2) + "  -  #{date_range}\n"
            else
              current_accrued = '0.00%'
            end

            current_accrued
          end
        end

        # if sub_investment.current_retained > 0
        div class: 'static-break' do
          panel('Current Interest Reserve', class: 'sub-investment-per-annum-panel retained-amount') do
            if sub_investment.current_retained.round(2).zero?
              number_to_currency 0, precision: 2
            else
              number_to_currency sub_investment.current_retained, precision: 2
            end
          end

          panel('Current Interest Reserve', class: 'sub-investment-per-annum-panel retained-percentage') do
            retained_periods = sub_investment.interest_periods
            if retained_periods.any?
              current_retained = ''
              retained_periods.each_cons(2) do |p|
                date_range = "#{p[0].effect_date} to #{p[1].effect_date}"
                current_retained += number_to_percentage(p[0].retained_per_annum,
                                                         precision: 2) + "  -  #{date_range}\n"
              end

              last_element = retained_periods.last
              date_range = "#{last_element.effect_date} to current"
              current_retained += number_to_percentage(last_element.retained_per_annum,
                                                       precision: 2) + "  -  #{date_range}\n"
            else
              current_retained = '0.00%'
            end

            current_retained
          end
        end
      end

      column do
        if current_admin_user.admin
          panel('Investment Description') do
            if can? :update, SubInvestment
              "#{sub_investment.description} <br> <div class='hide'>#{sub_investment.description}</div> #{link_to 'Edit Description',
                                                                                                                  '#', class: 'edit-sub-investment-description', data: { form_url: admin_sub_investment_path(id: sub_investment.id), field: 'description', model: 'sub_investment' }}".html_safe
            else
              sub_investment.description.to_s.html_safe
            end
          end
          panel('Private notes for Sub') do
            if can? :update, SubInvestment
              "#{sub_investment.private_note} <br> <div class='hide'>#{sub_investment.private_note}</div> #{link_to 'Edit Private note',
                                                                                                                    '#', class: 'edit-sub-investment-private-note', data: { form_url: admin_sub_investment_path(id: sub_investment.id), field: 'private_note', model: 'sub_investment' }}".html_safe
            else
              sub_investment.private_note.to_s.html_safe
            end
          end
        else

          if sub_investment.investment.all_images.count.positive?
            panel('Images') do
              div class: 'hide images-content' do
                sub_investment.investment.id
              end
            end
          end

          if sub_investment.investment.description
            panel('Investment Description') do
              sub_investment.investment.description.to_s.html_safe
            end
          end

          if sub_investment.description
            panel('Details for Sub-investment') do
              sub_investment.description.to_s.html_safe
            end
          end
        end
      end
    end

    if current_admin_user.admin?
      form action: "/admin/sub_investments/#{sub_investment.id}/payment_batch_action",
           class: 'batch-action-form', method: 'post' do
        input name: 'batch_action', id: 'batch_action', class: 'payment-batch-action', type: 'hidden'

        panel('Payments') do
          table_for(sub_investment.payments.order('DUE_DATE ASC'), id: 'index_table_payments',
                                                                   class: 'index_table index custom_sort_table') do
            # column "id" do |p|
            #  if p.payment_kind == Payment::Type_Accrued
            #    link_to p.id, admin_sub_accrued_payments_path(payment: p.id)
            #  else
            #    p.id
            #  end
            # end
            column :id
            column :paid_date
            column :due_date
            column 'admin_user_id', class: 'hide admin_user_id' do |item|
              item.admin_user.id
            end
            column 'name' do |p|
              link_to p.admin_user.name, admin_sub_investor_path(p.admin_user)
            end
            column 'amount' do |item|
              if item.payment_kind == Payment::Type_Accrued
                div 'class' => 'accrued-info', 'data-info' => item.remark.to_s.gsub("\n", '<br>'),
                    'data-amount' => number_to_currency(item.amount) do
                  div 'class' => 'icon'
                end
              elsif item.payment_kind == Payment::Type_Retained
                div 'class' => 'retained-info', 'data-info' => item.remark.to_s.gsub("\n", '<br>'),
                    'data-amount' => number_to_currency(item.amount) do
                  div 'class' => 'icon'
                end
              else
                number_to_currency item.amount
              end
            end
            column 'check_no'
            column 'Payment Type', &:payment_kind
            column 'memo'
            column('status') { |payment| status_tag(payment.status) }
            column do |p|
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
            end
          end
        end
      end
    end

    unless current_admin_user.admin?
      panel('Paid Payments') do
        table_for(sub_investment.customer_paid_payments) do
          column 'id'
          column 'due_date'
          column 'name' do |p|
            link_to p.admin_user.name, admin_sub_investor_path(p.admin_user)
          end
          column 'amount' do |item|
            number_to_currency item.amount
          end
          column 'check_no'
          column 'Payment Type', &:payment_kind
          column 'memo'
          column('status') { |payment| status_tag(payment.status) }
        end
      end
    end

    if sub_investment.withdraws.count.positive?
      panel(' Transactions') do
        table_for(sub_investment.withdraws.order(due_date: :asc)) do
          column 'id'
          column 'due_date' do |item|
            link_to item.due_date.strftime('%Y-%m-%d'),
                    "/admin/#{(item.type || 'withdraw').downcase.pluralize}/#{item.id}"
          end
          column :name
          column 'amount' do |item|
            number_to_currency item.amount
          end
          column 'check_no'
        end
      end
    end

    # unless sub_investment.sub_accrued_payments.count == 0
    #  panel("Monthly/Quarterly Accrued Payments") do
    #    table_for(sub_investment.sub_accrued_payments.order('due_date')) do
    #      column :id
    #      column :due_date
    #      column "amount" do | item |
    #        number_to_currency item.amount
    #      end
    #      column :payment
    #      column("status") {|sub_p| status_tag(sub_p.status) }
    #      column do |p|
    #        div style: 'display:inline' do
    #          link_to 'View', admin_sub_accrued_payment_path(p)
    #        end
    #        div style: 'display:inline' do
    #          link_to 'Edit', edit_admin_sub_accrued_payment_path(p)
    #        end
    #        div style: 'display:inline' do
    #          link_to 'Delete', "#{delete_accrued_payment_admin_sub_investment_path(sub_investment)}?accrued_payment_id=#{p.id}", data: { method: 'delete', confirm: 'Are you sure you want to delete this?' }
    #        end
    #      end
    #    end
    #  end
    # end

    if current_admin_user.admin && sub_investment.referrand_paid_payments.count.positive?
      panel('Paid Referrand Payments') do
        table_for(sub_investment.referrand_paid_payments) do
          column 'id'
          column 'due_date'
          column 'name' do |p|
            link_to p.admin_user.name, admin_sub_investor_path(p.admin_user)
          end
          column 'amount' do |item|
            number_to_currency item.amount
          end
          column 'check_no'
          column('status') { |payment| status_tag(payment.status) }
        end
      end
    end

    events = sub_investment.events.order('created_at asc')
    if events.count.positive? && current_admin_user.admin?
      panel('Events') do
        table_for(events) do
          column 'date'
          column 'description'
          column do |p|
            div style: 'display:inline' do
              link_to 'Delete', admin_event_path(p.id), data: { method: 'delete', confirm: 'Are you sure?' }
            end
          end
        end
      end
    end

    panel 'Investment Balance', id: 'amount_change_panel' do
      steps = sub_investment.current_amount_steps

      total_in = total_out = balance = 0

      steps.each do |step|
        total_in += (step.in || 0)
        total_out += (step.out || 0)
        balance = step.balance
      end

      div :id => 'amount_change_in', :class => 'hide', 'data-value' => number_to_currency(total_in)
      div :id => 'amount_change_out', :class => 'hide', 'data-value' => number_to_currency(total_out)
      div :id => 'amount_change_balance', :class => 'hide', 'data-value' => number_to_currency(balance)

      table_for(steps) do
        column 'date'
        column 'event' do |item|
          item.action.casecmp('withdraw').zero? ? 'Transactions' : item.action
        end
        column 'in' do |item|
          number_to_currency item.in
        end
        column 'out' do |item|
          number_to_currency item.out
        end
        column 'balance' do |item|
          number_to_currency item.balance
        end
      end
    end
  end

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
# rubocop:enable Rails/OutputSafety
