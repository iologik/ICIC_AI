# frozen_string_literal: true

ActiveAdmin.register_page 'Subinvestment Balance Report' do
  menu parent: 'Reports'

  controller do
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def index
      @total_balance = 0

      # set default investment status
      params[:investment_status_id_in] = [InvestmentStatus.active_status.id] if params[:investment_status_id_in].blank?

      sub_investments = SubInvestment.order(name: :asc).includes(:investment)

      sub_investments = sub_investments.where(id: params[:sub_investment_id_eq]) if params[:sub_investment_id_eq].present?

      sub_investments = sub_investments.where(admin_user_id: params[:sub_investor_id_eq]) if params[:sub_investor_id_eq].present?

      sub_investments = sub_investments.where(investments: { investment_kind_id: params[:investment_kind_id_eq] }) if params[:investment_kind_id_eq].present?

      sub_investments = sub_investments.where(investments: { investment_source_id: params[:investment_source_id_in] }) if params[:investment_source_id_in].present?

      sub_investments = sub_investments.where(investment_status_id: params[:investment_status_id_in]) if params[:investment_status_id_in].present?

      sub_investments = sub_investments.where(currency: params[:currency_eq]) if params[:currency_eq].present?

      count_per_page  = 30

      @total_of_all_pages_usd = @total_of_all_pages_cad = 0

      @sub_investments = if params[:up_to_date]
                           sub_investments.map do |sub_investment|
                             sub_investment.balance = sub_investment.calc_balance(params[:up_to_date])

                             sub_investment
                           end
                         else
                           sub_investments.map do |sub_investment|
                             sub_investment.balance = sub_investment.amount

                             sub_investment
                           end
                         end

      if params[:balance_eq].present? && params[:balance_eq] == '$0.00'
        @sub_investments = @sub_investments.filter { |sub_investment| sub_investment.balance.zero? }
      elsif params[:balance_eq].nil? || params[:balance_eq] == 'Not $0.00'
        @sub_investments = @sub_investments.filter { |sub_investment| sub_investment.balance != 0 }
      end

      @total_page     = (@sub_investments.count + count_per_page - 1) / count_per_page
      @current_page   = [params[:page].to_i, 1].max
      @total_num      = @sub_investments.count
      @page_from_id   = ((@current_page - 1) * count_per_page) + 1
      @page_to_id     = [@current_page * count_per_page, @total_num].min
      @show_from_id   = [@current_page - 1, 1].max
      @show_to_id     = @show_from_id + 2

      if params[:type] == 'pdf'
        balance_report = BuildBalanceReportService.new.call(
          @sub_investments,
          params[:up_to_date] || Time.zone.today.to_s,
          !!params[:sort_by_subinvestment] && !params[:sub_investor_id_eq]
        )
        send_data balance_report.render, type: 'application/pdf', disposition: 'inline'
      else
        @sub_investments.each do |sub_investment|
          if sub_investment.currency == 'USD'
            @total_of_all_pages_usd += sub_investment.balance
          else
            @total_of_all_pages_cad += sub_investment.balance
          end
        end

        @sub_investments = @sub_investments[@page_from_id - 1, count_per_page] || []

        @total_balance_usd = @total_balance_cad = 0
        @sub_investments.each do |sub_investment|
          if sub_investment.currency == 'USD'
            @total_balance_usd += sub_investment.balance
          else
            @total_balance_cad += sub_investment.balance
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end

  content title: 'Investor Balance Report' do
    render 'index'
  end
end
