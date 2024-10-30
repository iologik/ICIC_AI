# frozen_string_literal: true

ActiveAdmin.register InvestmentProfit do
  menu parent: 'Reports'

  actions :all, except: %i(edit update new create destroy)

  config.sort_order = nil
  config.filters = false
  config.batch_actions = false
  config.paginate = false

  controller do
    # rubocop:disable Rails/DynamicFindBy
    # rubocop:disable Metrics/AbcSize
    def index
      scopes = InvestmentProfitYear.currencies_and_years
      currency = params[:currency] || scopes[0]['currency']
      year = params[:year] || scopes[0]['year']
      accumulated = (params[:accumulated] == 'true')

      Thread.current[:accumulated] = accumulated

      profits = accumulated ? InvestmentProfit.find_by(currency: currency) : InvestmentProfitYear.find_by_currency_and_year(currency, year)

      @investment_profits = Kaminari.paginate_array(profits).page(1).per(10_000)

      super do |format|
        format.pdf do
          if accumulated
            send_data BuildInvestmentProfitsService.new.call(@investment_profits).render, type: 'application/pdf', disposition: 'inline'
          else
            send_data BuildInvestmentProfitYearService.new.call(@investment_profits, year).render, type: 'application/pdf', disposition: 'inline'
          end
          # send_data renders the pdf on the client side rather than saving it on the server filesystem.
          # Inline disposition renders it in the browser rather than making it a file download.
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Rails/DynamicFindBy

    private

    def save_search_criteria
      session[:payment_index_url] = request.original_url
    end
  end

  index do
    scopes = InvestmentProfitYear.currencies_and_years
    currency = params[:currency] || scopes[0]['currency']
    year = params[:year] || scopes[0]['year']

    div :class => 'scopes-content hide', 'data-currency' => currency, 'data-year' => year,
        'data-accumulated' => Thread.current[:accumulated] do
      (InvestmentProfitYear.currencies_and_years.pluck('year').uniq + ['ALL']).to_json
    end

    initial_amount_total = current_amount_total = gross_profit_total = all_paid_payments_amount = sub_balance = 0
    investment_profits.each do |invest|
      initial_amount_total += invest.ori_amount
      current_amount_total += year == 'ALL' ? invest.amount : invest.distribution_by_year(year.to_i)
      gross_profit_total += invest.revenue.to_f
      all_paid_payments_amount += invest.paid_out.to_f
      sub_balance += invest.sub_balance.to_f
    end

    div class: 'initial_amount_total hide' do
      number_to_currency(initial_amount_total, precision: 2)
    end
    div class: 'current_amount_total hide' do
      number_to_currency(current_amount_total, precision: 2)
    end
    div class: 'gross_profit_total hide' do
      number_to_currency(gross_profit_total, precision: 2)
    end
    div class: 'all_paid_payments_amount hide' do
      number_to_currency(all_paid_payments_amount, precision: 2)
    end
    div class: 'sub_balance hide' do
      if sub_balance.negative?
        label class: 'negative' do
          number_to_currency(sub_balance, precision: 2)
        end
      else
        number_to_currency(sub_balance, precision: 2)
      end
    end

    column 'Investment' do |investment|
      link_to investment.name, admin_investment_path(investment.id)
    end
    column :year unless Thread.current[:accumulated]
    # column :start_date
    # column :archive_date
    column 'Currency', &:currency
    column 'Initial Amount' do |investment|
      number_to_currency(investment.ori_amount, precision: 2)
    end
    column 'Current Amount' do |investment|
      if !Thread.current[:accumulated] && year != 'ALL'
        number_to_currency(investment.distribution_by_year(year.to_i), precision: 2)
      else
        number_to_currency(investment.amount, precision: 2)
      end
    end
    column 'Revenue Income' do |investment|
      number_to_currency(investment.revenue, precision: 2)
    end
    column 'Interest Paid Out' do |investment|
      number_to_currency(investment.paid_out, precision: 2)
    end
    column 'Net Income', class: 'row net-income' do |investment|
      if investment.sub_balance.negative?
        label class: 'negative' do
          number_to_currency(investment.sub_balance, precision: 2)
        end
      else
        number_to_currency(investment.sub_balance, precision: 2)
      end
    end
    # column "Accrued Payable" do |investment|
    #  number_to_currency(investment.accrued_payable, :precision => 2)
    # end
    # column "Interest Reserve Payable" do |investment|
    #  number_to_currency(investment.retained_payable, :precision => 2)
    # end
    # column "Net Net Income", class: 'row net-income' do |investment|
    #  if investment.net_income < 0
    #    label class: 'negative' do
    #      number_to_currency(investment.net_income, :precision => 2)
    #    end
    #  else
    #    number_to_currency(investment.net_income, :precision => 2)
    #  end
    # end
  end
end
