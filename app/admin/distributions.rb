# frozen_string_literal: true

ActiveAdmin.register Distribution do
  menu false

  permit_params :investment_id,
                :return_of_capital,
                :gross_profit,
                :cash_reserve,
                :date, :description,
                :withholding_tax,
                :holdback_state

  controller do
    before_action :save_url, only: :show

    def new
      @distribution = Distribution.new
      @distribution.date = Time.zone.today
      return if params[:investment].blank?

      @distribution.investment_id = params[:investment]
    end

    def destroy
      distribution = Distribution.find(params[:id])
      distribution.destroy
      redirect_to admin_investment_path(distribution.investment)
    end

    private

    def save_url
      session[:sub_distribution_index_url] = request.original_url
    end
  end

  form do |f|
    f.inputs do
      f.input :investment, include_blank: true
      f.input :return_of_capital
      f.input :gross_profit
      f.input :cash_reserve
      f.input :withholding_tax, label: 'Holdback Fed'
      f.input :holdback_state
      f.input :date, order: %i(year month day), use_two_digit_numbers: true
      f.input :description, input_html: { style: 'height: 100px;' }
    end

    f.actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :id
          row :investment
          row :return_of_capital do |item|
            number_to_currency item.return_of_capital, precision: 2
          end
          row 'Holdback Fed' do |item|
            number_to_currency item.withholding_tax, precision: 2
          end
          row :holdback_state do |item|
            number_to_currency item.holdback_state, precision: 2
          end
          row :gross_profit do |item|
            number_to_currency item.gross_profit, precision: 2
          end
          row 'Net Cash' do |item|
            number_to_currency item.net_cash, precision: 2
          end
          row :date
          row :description
        end
      end
    end
  end

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
