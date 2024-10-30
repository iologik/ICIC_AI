# frozen_string_literal: true

ActiveAdmin.register_page 'Investment Balance Report' do
  menu parent: 'Reports'

  controller do
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def index
      @total_balance = 0

      # set default investment status
      params[:investment_status_id_in] = [InvestmentStatus.active_status.id] if params[:investment_status_id_in].blank?

      investments = Investment.order(name: :asc)

      investments = investments.where(id: params[:investment_id_eq]) if params[:investment_id_eq].present?

      investments = investments.where(investment_kind_id: params[:investment_kind_id_eq]) if params[:investment_kind_id_eq].present?

      investments = investments.where(investment_source_id: params[:investment_source_id_in]) if params[:investment_source_id_in].present?

      investments = investments.where(investment_status_id: params[:investment_status_id_in]) if params[:investment_status_id_in].present?

      investments = investments.where(currency: params[:currency_eq]) if params[:currency_eq].present?

      if params[:balance_eq].present? && params[:balance_eq] == '$0.00'
        investments = investments.where(amount: 0)
      elsif params[:balance_eq].nil? || params[:balance_eq] == 'Not $0.00'
        investments = investments.where.not(amount: 0)
      end

      count_per_page = 30
      @total_page = (investments.count + count_per_page - 1) / count_per_page
      @current_page = [params[:page].to_i, 1].max
      @total_num = investments.count
      @page_from_id = ((@current_page - 1) * count_per_page) + 1
      @page_to_id = [@current_page * count_per_page, @total_num].min
      @show_from_id = [@current_page - 1, 1].max
      @show_to_id = @show_from_id + 2

      @total_of_all_pages_usd = @total_of_all_pages_cad = 0

      @investments = if params[:up_to_date]
                       investments.map do |investment|
                         investment.balance = investment.calc_balance(nil, params[:up_to_date])

                         investment
                       end
                     else
                       investments.map do |investment|
                         investment.balance = investment.amount

                         investment
                       end
                     end

      if params[:type] == 'pdf'
        investment_balance_report = BuildInvestmentBalanceReportService.new.call(@investments,
                                                                                 params[:up_to_date] || Time.zone.today.to_s)
        send_data investment_balance_report.render, type: 'application/pdf', disposition: 'inline'
      else
        @investments.each do |investment|
          if investment.currency == 'USD'
            @total_of_all_pages_usd += investment.balance
          else
            @total_of_all_pages_cad += investment.balance
          end
        end

        @investments = @investments[@page_from_id - 1, count_per_page]

        @total_balance_usd = @total_balance_cad = 0
        @investments.each do |investment|
          if investment.currency == 'USD'
            @total_balance_usd += investment.balance
          else
            @total_balance_cad += investment.balance
          end
        end
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize
  end

  content title: 'Investment Balance Report' do
    render 'index'
  end
end
