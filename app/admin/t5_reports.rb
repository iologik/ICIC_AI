# frozen_string_literal: true

ActiveAdmin.register_page 'T5 Report' do
  menu parent: 'Reports'

  controller do
    def index
      @current_year = Time.zone.today.year

      @year = params['year'] || @current_year
      @investment_source_ids = (params['investment_source_ids'] || InvestmentSource.pluck(:id)).map(&:to_i)

      @payment_type = params[:payment_type] || %w(Interest Accrued Retained AMF MISC)
      @payment_type_query = ''
      @payment_type.each do |type|
        @payment_type_query += "payment_type[]=#{type}&"
      end

      @reports = T5Report.payments_by_year(@year, @investment_source_ids, @payment_type)
    end
  end

  content title: 'T5 Report' do
    render 'index'
  end
end
