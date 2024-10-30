# frozen_string_literal: true

ActiveAdmin.register Investment do
  permit_params :name,
                :investment_kind_id,
                :amount,
                :description,
                { images: [] },
                :investment_status_id,
                :exchange_rate,
                :investment_source_id,
                :expected_return_percent,
                :private_note,
                :ori_amount,
                :start_date,
                :icic_committed_capital,
                :currency,
                :address,
                :legal_name,
                :location,
                :fee_type,
                :fee_amount,
                :memo,
                :initial_description

  csv do
    column :id
    column :name
    column :amount
    column :exchange_rate
    column :expected_return_percent
    column :created_at
    column :updated_at
    column :year_paid
    column :ori_amount
    column :start_date
    column :currency
    column :address
    column :legal_name
    column :location
    column :archive_date
    column :fee_type
    column :fee_amount
    column :memo
    column :initial_description
    column :money_raised_amount
    column :cash_reserve_amount
    column :cad_money_raised_amount
    column :icic_committed_capital
    column :sub_amount_total
    column :sub_ownership_percent_sum
    column :sub_per_annum_sum
    column :sub_accrued_percent_sum
    column :sub_retained_percent_sum
    column :distrib_return_of_capital
    column :distrib_withholding_tax
    column :distrib_holdback_state
    column :distrib_gross_profit
    column :distrib_cash_reserve
    column :distrib_net_cash
    column :draw_amount
    column :distribution_draw_amount
    column :accrued_payable_amount
    column :retained_payable_amount
    column :gross_profit_total_amount
    column :all_paid_payments_amount
    column :sub_balance_amount
    column :net_income_amount
    column :postal_code
  end
  config.per_page = 30

  menu priority: 2
  config.sort_order = 'name_asc'
  # Disable all batch actions
  config.batch_actions = false

  actions :all, except: [:destroy]

  filter :name, label: 'by Investment Name'
  filter :investment_kind
  # rubocop:disable Rails/UniqBeforePluck
  filter :investment_source, label: 'Investment Source', as: :check_boxes, collection: InvestmentSource.reorder(:priority).pluck(:name, :id).uniq
  filter :investment_status, as: :check_boxes, collection: InvestmentStatus.pluck(:name, :id).uniq
  # rubocop:enable Rails/UniqBeforePluck
  filter :currency, as: :select, collection: %w(CAD USD)

  controller do
    skip_before_action :verify_authenticity_token, only: %i(update generate_report)
    before_action :flag_active, :flag_currency, only: :index

    before_action only: [:index] do
      params['q'] = { investment_status_id_in: [InvestmentStatus.find_by(name: 'Active').id] } if !params[:q] || params[:q][:investment_status_id_in].blank?
    end

    def new
      @investment = Investment.new
      @investment.investment_source = InvestmentSource.default_icic
    end

    def index
      super do |format|
        format.pdf { render(pdf: 'investments.pdf') }
      end
    end

    private

    def flag_active
      # TODO: sometimes Thread.current["visit_index"] is true by default...weird...
      # The current code is okay for the app
      Thread.current['visit_index'] = params['commit'] != 'Filter'
    end

    # "q"=>{"investment_status_id_eq"=>"3", "currency_eq"=>"CAD"}
    def flag_currency
      Thread.current['filter_currency'] = if params['q'] && (currency = params['q']['currency_eq'])
                                            currency
                                          else
                                            false
                                          end
    end
  end

  member_action :activate, method: :get do
    investment = Investment.find(params[:id])
    investment.status = ''
    investment.save
    redirect_to "/admin/investments/#{investment.id}"
  end

  member_action :invest, method: :get do
    inv = Investment.find(params[:id])
    user = current_admin_user
    redirect_to "/admin/sub_investments/new?user=#{user.id}&investment=#{inv.id}"
  end

  member_action :images_panel, method: :get do
    invest = Investment.find(params[:id])
    render json: { page: render_to_string('admin/investments/_images_panel', layout: false, locals: { invest: invest }) }
  end

  member_action :destroy_self, method: :delete do
    investment = Investment.find(params[:id])
    if current_admin_user.admin?
      investment.destroy
      redirect_to admin_investments_path
    end
  end

  member_action :sub_investment_ids, method: :get do
    investment = Investment.find(params[:id])
    render json: investment.sub_investments.pluck(:id)
  end

  action_item :invest, only: :show do
    if current_admin_user.admin?
      link_to 'Invest', "/admin/investments/#{investment.id}/invest"
    else
      link_to('Request to invest', "/admin/invests/new?investment_id=#{investment.id}")
    end
  end

  action_item :distribution, only: :show do
    if current_admin_user.admin?
      link_to 'Distribution', "/admin/distributions/new?investment=#{investment.id}",
              id: 'distribution_button'
    end
  end

  action_item :draw, only: :show do
    link_to 'Draw', "/admin/draws/new?investment=#{investment.id}", id: 'draw_button' if current_admin_user.admin?
  end

  action_item :sub_distributions, only: :show do
    link_to 'Sub Distributions', "/admin/sub_distributions?investment=#{investment.id}" if current_admin_user.admin?
  end

  action_item :Delete, only: :show do
    if current_admin_user.admin?
      link_to 'Delete Investment', "/admin/investments/#{investment.id}/destroy_self", method: 'delete',
                                                                                       data: { confirm: 'Are you sure you want to delete all related Sub Investment and Payments' }
    end
  end

  action_item :detail_report, only: :show do
    link_to 'Detailed Report', '#', id: 'detailed_report'
  end

  # dashboard analytics

  collection_action :dashboard_content, method: :get do
    render json: { page: render_to_string("admin/investments/_#{params[:column]}_column", layout: false),
                   column: params[:column] }
  end

  member_action :generate_report, method: :post do
    investment = Investment.find(params[:id])

    pdf = BuildInvestmentReportService.new.call(investment, params[:start_date_str], params[:end_date_str],
                                                params[:transaction_type])

    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  end
  #
  # Pls format the $$ numbers, let's show: ID, NAME (linkable), Amount, Money Raised, Balance (calc field, Amount - Money Raised).

  form(html: { multipart: true }) do |f|
    f.inputs do
      f.input :name
      f.input :location
      f.input :legal_name
      f.input :address, label: 'Legal address'
      f.input :postal_code, label: 'Postal Code'
      if f.object.new_record?
        f.input :amount
      else
        f.input :amount, input_html: { class: 'edit-investment-amount', disabled: 'disabled' }
        # f.input :ori_amount # will hide in css
      end
      f.input :memo
      f.input :currency, as: :radio, collection: %w(USD CAD)
      f.input :investment_source, include_blank: false
      f.input :investment_kind, include_blank: false
      f.input :investment_status, include_blank: false
      f.input :start_date, order: %i(year month day), use_two_digit_numbers: true, start_year: 2007
      f.input :icic_committed_capital

      f.input :images, as: :file, input_html: { multiple: true }
      f.input :exchange_rate
      div :class => 'hide current_exchange_rate', 'data-rate' => Investment.latest_rate,
          'data-cad-usd-rate' => Investment.latest_rate('CAD')

      f.input :expected_return_percent

      f.input :fee_type
      f.input :fee_amount

      div class: 'hide initial-description-wrapper'

      f.actions
    end
  end

  index do
    div class: 'hide real-investment-index' if Thread.current['visit_index']

    if (currency = Thread.current['filter_currency'])
      sql = "select sum(amount) from sub_investments where (currency = '#{currency}') and (admin_user_id=92 or admin_user_id=96)"
      kr_adjustments = ActiveRecord::Base.connection.execute(sql).first['sum'].to_f
      div :class => 'hide filter-currency', 'data-currency' => currency do
        kr_adjustments
      end
    end

    amount_total = 0
    money_raised_total = 0
    cash_reserve_total = 0
    money_raised_total_cad = 0
    cash_reserve_total_cad = 0
    money_raised_total_usd = 0
    cash_reserve_total_usd = 0
    money_raised_total_cad_all = 0
    cash_reserve_total_cad_all = 0
    money_raised_total_usd_all = 0
    cash_reserve_total_usd_all = 0

    investments.where(currency: 'USD').to_a.sum(&:amount)
    investments.where(currency: 'CAD').to_a.sum(&:amount)
    investments.each do |p|
      if p.currency == 'USD'
        money_raised_total_usd += (p.money_raised_amount ||= 0)
        cash_reserve_total_usd += (p.cash_reserve_amount ||= 0)
      elsif p.currency == 'CAD'
        money_raised_total_cad += (p.cad_money_raised_amount ||= 0)
        cad_cash_reserve_amount = p.cad_cash_reserve_amount
        cash_reserve_total_cad += (cad_cash_reserve_amount || 0)
      end

      if Thread.current['filter_currency']
        amount_total += (p.amount ||= 0)
        money_raised_total += (p.money_raised_amount ||= 0)
        cash_reserve_total += (p.cash_reserve_amount ||= 0)
      else
        amount_total += (p.cad_amount ||= 0)
        money_raised_total += (p.cad_money_raised_amount ||= 0)
        cad_cash_reserve_amount = p.cad_cash_reserve_amount
        cash_reserve_total += (cad_cash_reserve_amount || 0)
      end
    end

    total_investments = investments.unscope(%i(offset limit))
    total_cad_investments = total_investments.where(currency: 'CAD')
    total_usd_investments = total_investments.where(currency: 'USD')

    total_cad_investments.sum(:amount)
    money_raised_total_cad_all = total_cad_investments.sum(:cad_money_raised_amount)
    cash_reserve_total_cad_all = total_cad_investments.sum(:cash_reserve_amount)

    total_usd_investments.sum(:amount)
    money_raised_total_usd_all = total_usd_investments.sum(:money_raised_amount)
    cash_reserve_total_usd_all = total_usd_investments.sum(:cash_reserve_amount)

    investment_ids = investments.pluck(:id)
    tinvestments = Investment.where(id: investment_ids)
    total_amount = tinvestments.sum(:amount)

    total_amount_cad = tinvestments.where(currency: 'CAD').sum(:amount)
    total_amount_usd = tinvestments.where(currency: 'USD').sum(:amount)

    total_amount_cad_all = Investment.ransack(params[:q]).result.where(currency: 'CAD').sum(:amount)
    total_amount_usd_all = Investment.ransack(params[:q]).result.where(currency: 'USD').sum(:amount)

    # hidden data
    div class: 'hide amount-total investment-page' do
      number_to_currency(total_amount, precision: 2)
    end
    div class: 'hide money-raised-total investment-page' do
      money_raised_total
    end
    div class: 'hide cash-reserve-total investment-page' do
      cash_reserve_total
    end
    div class: 'hide balance-total investment-page' do
      total_amount - money_raised_total + cash_reserve_total
    end
    # current page cad
    div class: 'hide amount-total-cad investment-page' do
      number_to_currency(total_amount_cad, precision: 2)
    end
    div class: 'hide money-raised-total-cad investment-page' do
      money_raised_total_cad
    end
    div class: 'hide balance-total-cad investment-page' do
      total_amount_cad - money_raised_total_cad + cash_reserve_total_cad
    end

    # current page usd
    div class: 'hide amount-total-usd investment-page' do
      number_to_currency(total_amount_usd, precision: 2)
    end
    div class: 'hide money-raised-total-usd investment-page' do
      money_raised_total_usd
    end
    div class: 'hide balance-total-usd investment-page' do
      total_amount_usd - money_raised_total_usd + cash_reserve_total_usd
    end

    # total all cad
    div class: 'hide amount-total-cad-all investment-page' do
      number_to_currency(total_amount_cad_all, precision: 2)
    end
    div class: 'hide money-raised-total-cad-all investment-page' do
      money_raised_total_cad_all
    end
    div class: 'hide balance-total-cad-all investment-page' do
      total_amount_cad_all - money_raised_total_cad_all + cash_reserve_total_cad_all
    end

    # total all usd
    div class: 'hide amount-total-usd-all investment-page' do
      number_to_currency(total_amount_usd_all, precision: 2)
    end
    div class: 'hide money-raised-total-usd-all investment-page' do
      money_raised_total_usd_all
    end
    div class: 'hide balance-total-usd-all investment-page' do
      total_amount_usd_all - money_raised_total_usd_all + cash_reserve_total_usd_all
    end

    column :name, sortable: :name do |o|
      link_to o.name, "/admin/investments/#{o.id}"
    end

    column :amount do |o|
      number_to_currency(o.amount, precision: 2)
    end
    column 'Funded' do |o|
      number_to_currency(o.money_raised_amount, precision: 2)
    end
    column 'Cash Reserve' do |o|
      number_to_currency(o.cash_reserve_amount, precision: 2)
    end
    column :balance do |o|
      amount = o.amount ||= 0
      money_raised_amount = o.money_raised_amount ||= 0
      cash_reserve_amount = o.cash_reserve_amount ||= 0
      balance = amount - money_raised_amount + cash_reserve_amount
      if balance.negative?
        label style: 'color:#EC4242' do
          number_to_currency(balance, precision: 2)
        end
      else
        number_to_currency(balance, precision: 2)
      end
    end

    column :currency
    column :start_date

    actions
  end

  show do
    ################## these variables are for total info for sub-investments panel, and sub_current_accrued_sum and sub_current_retained_sum are also displayed on paid out to date panel
    sub_current_accrued_sum = investment.accrued_payable_amount
    sub_current_retained_sum = investment.retained_payable_amount

    ##################

    div :class => 'hide', :id => 'info', 'data-id' => investment.id

    columns do
      column id: 'investment_details_panel' do
        panel 'Investment Details' do
          attributes_table_for investment do
            # row :name
            row :location
            row :legal_name
            row :legal_address, &:address
            row :postal_code
            row 'current amount' do |o|
              "#{number_to_currency(o.amount, precision: 2)} #{o.currency}"
            end
            row :memo
            # row :ori_amount do | o|
            #  number_to_currency(o.ori_amount ,:precision => 2)
            # end
            row 'Funded' do |o|
              number_to_currency(o.money_raised_amount, precision: 2)
            end
            row :exchange_rate
            row :investment_source
            row :expected_return_percent
            row :investment_kind
            row :investment_status
            row :start_date
            row :icic_committed_capital do |o|
              number_to_currency(o.icic_committed_capital, precision: 2)
            end
          end
        end

        panel 'Income / Expense' do
          attributes_table_for investment do
            row 'Revenue Income' do |investment|
              "#{number_to_currency(investment.gross_profit_total_amount, precision: 2)} #{investment.currency}"
            end
            row 'Interest Paid Out' do |investment|
              number_to_currency(investment.all_paid_payments_amount, precision: 2)
            end
            row 'Sub Balance', class: 'row net-income' do |investment|
              number_to_currency(investment.sub_balance_amount, precision: 2)
            end
            row 'ACCRUED PAYABLE' do |investment|
              number_to_currency(investment.accrued_payable_amount, precision: 2)
            end
            row 'RETAINED PAYABLE' do |investment|
              number_to_currency(investment.retained_payable_amount, precision: 2)
            end
            row 'Net Income', class: 'row net-income' do |investment|
              number_to_currency(investment.net_income_amount, precision: 2)
            end
          end
        end

        panel 'Fee' do
          attributes_table_for investment do
            row :fee_type
            row :fee_amount
          end
        end
      end

      column do
        if investment.all_images.count.positive?
          panel('Images') do
            div class: 'hide images-content' do
              resource.id
            end
          end
        end

        if investment.posts.count.positive?
          panel('The latest update') do
            update = investment.posts.order('created_at desc').first
            link_to update.title,
                    admin_updates_path({ 'utf8' => '✓', 'q' => { 'investment_id_eq' => update.investment_id.to_s }, 'commit' => 'Filter',
                                         'order' => 'id_desc' })
          end
        end

        # rubocop:disable Rails/OutputSafety
        panel('Investment Details') do
          "#{investment.description} <br> <div class='hide'>#{investment.description}</div> #{link_to 'Edit Description',
                                                                                                      '#', class: 'edit-investment-description', data: { form_url: admin_investment_path(id: investment.id), field: 'description', model: 'investment' }}".html_safe
        end

        panel('Private Note') do
          "#{investment.private_note} <br> <div class='hide'>#{investment.private_note}</div> #{link_to 'Edit Private note',
                                                                                                        '#', class: 'edit-investment-private-note', data: { form_url: admin_investment_path(id: investment.id), field: 'private_note', model: 'investment' }}".html_safe
        end
        # rubocop:enable Rails/OutputSafety
      end
    end

    if current_admin_user.admin?
      sub_count = investment.sub_investments.count

      # statistics info
      if sub_count.positive?
        sub_per_annum_avg = investment.sub_amount_total.zero? ? 0 : investment.sub_per_annum_sum / investment.sub_amount_total
        sub_accrued_percent_avg = investment.sub_amount_total.zero? ? 0 : investment.sub_accrued_percent_sum / investment.sub_amount_total
        sub_retained_percent_avg = investment.sub_amount_total.zero? ? 0 : investment.sub_retained_percent_sum / investment.sub_amount_total

        div class: 'hide sub_amount_total' do
          number_to_currency(investment.sub_amount_total, precision: 2)
        end
        div class: 'hide sub_ownership_percent_sum' do
          number_to_percentage(investment.sub_ownership_percent_sum, precision: 2)
        end
        div class: 'hide sub_per_annum_avg' do
          number_to_percentage(sub_per_annum_avg, precision: 2)
        end
        div class: 'hide sub_accrued_percent_avg' do
          number_to_percentage(sub_accrued_percent_avg, precision: 2)
        end
        div class: 'hide sub_current_accrued_sum' do
          number_to_currency(sub_current_accrued_sum, precision: 2)
        end
        div class: 'hide sub_retained_percent_avg' do
          number_to_percentage(sub_retained_percent_avg, precision: 2)
        end
        div class: 'hide sub_current_retained_sum' do
          number_to_currency(sub_current_retained_sum, precision: 2)
        end
      end

      # panel
      panel('Sub Investments', id: 'investment_sub_investments',
                               class: ('imor' if investment.investment_source.imor?).to_s) do
        table_for(investment.sub_investments.order(name: :asc)) do
          column 'id' do |sub_investment|
            link_to sub_investment.id, admin_sub_investment_path(sub_investment.id)
          end

          column 'start date' do |invest|
            link_to invest.start_date.strftime('%Y-%m-%d'), admin_sub_investment_path(invest.id)
          end

          column 'name' do |invest|
            state = (invest.amount.zero? ? 'archived' : 'active')
            link_to invest.admin_user.name, admin_sub_investment_path(invest.id), 'data-state' => state
          end

          column :account do |invest|
            invest.account&.name
          end

          column '% ownership' do |invest|
            percent = invest.investment.amount.zero? ? 0 : invest.ownership_amount / invest.investment.amount * 100
            link_to number_to_percentage(percent, precision: 2), "/admin/sub_investments/#{invest.id}"
          end

          column 'amount' do |invest|
            if invest.different_currency?
              link_to "#{number_to_currency(invest.ownership_amount, precision: 2)} #{invest.investment.currency}",
                      "/admin/sub_investments/#{invest.id}", class: 'has-under-value', data: { 'under-value' => "#{number_to_currency(invest.amount, precision: 2)} #{invest.currency}" }
            else
              link_to "#{number_to_currency(invest.ownership_amount, precision: 2)} #{invest.investment.currency}",
                      "/admin/sub_investments/#{invest.id}"
            end
          end

          # column "months"
          column 'scheduled'
          column 'Interest P.A' do |invest|
            link_to number_to_percentage(invest.per_annum, precision: 2), "/admin/sub_investments/#{invest.id}"
          end
          column 'ACCRUED PAYABLE' do |invest|
            if invest.different_currency?
              link_to number_to_currency(invest.current_accrued_amount, precision: 2).to_s,
                      "/admin/sub_investments/#{invest.id}", class: 'has-under-value', data: { 'under-value' => "#{number_to_currency(invest.current_accrued_subinvest_currency, precision: 2)} #{invest.currency}" }
            else
              link_to number_to_currency(invest.current_accrued_amount, precision: 2).to_s,
                      "/admin/sub_investments/#{invest.id}"
            end
          end
          column 'RETAINED PAYABLE' do |invest|
            if invest.different_currency?
              link_to number_to_currency(invest.current_retained_amount, precision: 2).to_s,
                      "/admin/sub_investments/#{invest.id}", class: 'has-under-value', data: { 'under-value' => "#{number_to_currency(invest.current_retained_subinvest_currency, precision: 2)} #{invest.currency}" }
            else
              link_to number_to_currency(invest.current_retained_amount, precision: 2).to_s,
                      "/admin/sub_investments/#{invest.id}"
            end
          end
          column 'status'
        end
      end
    end

    if current_admin_user.admin?

      distribution_draws = (investment.distributions.to_a + investment.draws.to_a).sort_by(&:date)

      if distribution_draws.count.positive?
        div class: 'hide return_of_capital' do
          number_to_currency(investment.distrib_return_of_capital, precision: 2)
        end
        div class: 'hide withholding_tax' do
          number_to_currency(investment.distrib_withholding_tax, precision: 2)
        end
        div class: 'hide holdback_state' do
          number_to_currency(investment.distrib_holdback_state, precision: 2)
        end
        div class: 'hide gross_profit' do
          number_to_currency(investment.distrib_gross_profit, precision: 2)
        end
        div class: 'hide cash_reserve' do
          number_to_currency(investment.distrib_cash_reserve, precision: 2)
        end
        div class: 'hide net_cash' do
          number_to_currency(investment.distrib_net_cash, precision: 2)
        end

        div class: 'hide draw-amount' do
          number_to_currency(investment.draw_amount, precision: 2)
        end

        # compute balance
        current_amount = 0
        distribution_draws.each_with_index do |distribution_draw, _i|
          if distribution_draw.instance_of?(Draw)
            current_amount += distribution_draw.amount
          else
            current_amount -= distribution_draw.return_of_capital
          end
          distribution_draw.balance = current_amount
        end
        div class: 'hide current_amount' do
          number_to_currency(current_amount, precision: 2)
        end
      end

      # Distributions/Draws date using hidden tag

      distribution_draws.each do |distribution_draw, _i|
        data_type = if distribution_draw.instance_of?(Draw)
                      'draw'
                    else
                      'distribution'
                    end

        div :class => 'hide distribution-draw', 'data-id' => distribution_draw.id, 'data-type' => data_type,
            'data-date' => distribution_draw.date.strftime('%Y-%m-%d')
      end

      # Date, Description, Return of capital, draw amount, balance, gross profit
      panel('Distributions / Draws', id: 'investment_distribution_draws') do
        table_for(distribution_draws) do
          column :date do |item|
            if item.instance_of?(Distribution)
              link_to item.date.strftime('%Y-%m-%d'), "/admin/distributions/#{item.id}"
            else
              link_to item.date.strftime('%Y-%m-%d'), "/admin/draws/#{item.id}"
            end
          end
          column :description
          column 'Holdback Fed' do |item|
            if item.instance_of?(Distribution)
              link_to number_to_currency(item.withholding_tax, precision: 2),
                      "/admin/distributions/#{item.id}"
            end
          end
          column 'Holdback State' do |item|
            if item.instance_of?(Distribution)
              link_to number_to_currency(item.holdback_state || 0, precision: 2),
                      "/admin/distributions/#{item.id}"
            end
          end
          column 'Gross profit' do |item|
            if item.instance_of?(Distribution)
              link_to number_to_currency(item.gross_profit, precision: 2),
                      "/admin/distributions/#{item.id}"
            end
          end
          column 'Cash reserve' do |item|
            if item.instance_of?(Distribution)
              link_to number_to_currency(item.cash_reserve || 0, precision: 2),
                      "/admin/distributions/#{item.id}"
            end
          end
          column 'Net Cash' do |item|
            if item.instance_of?(Distribution)
              link_to number_to_currency(item.net_cash, precision: 2),
                      "/admin/distributions/#{item.id}"
            end
          end
          column 'Return of capital' do |item|
            if item.instance_of?(Distribution)
              link_to number_to_currency(item.return_of_capital, precision: 2),
                      "/admin/distributions/#{item.id}"
            end
          end
          column 'Capital Invested' do |item|
            if item.instance_of?(Draw)
              link_to number_to_currency(item.amount, precision: 2),
                      "/admin/draws/#{item.id}"
            end
          end
          column 'Balance' do |item|
            number_to_currency(item.balance, precision: 2)
          end
        end
      end
    end
  end

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
