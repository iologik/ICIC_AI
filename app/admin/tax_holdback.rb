# frozen_string_literal: true

ActiveAdmin.register TaxHoldback do
  menu parent: 'Reports'

  actions :all, except: %i(edit update new create destroy)

  config.sort_order = nil
  config.filters = false
  config.batch_actions = false
  config.paginate = false

  controller do
    def index
      @tax_holdback = kaminari_pagination

      super do |format|
        format.pdf do
          send_data BuildTaxHoldbackService.new.call(@tax_holdback).render, type: 'application/pdf', disposition: 'inline'
          # send_data renders the pdf on the client side rather than saving it on the server filesystem.
          # Inline disposition renders it in the browser rather than making it a file download.
        end
      end
    end

    def kaminari_pagination
      set_thread_values
      Kaminari.paginate_array(tax_holdbacks).page(1).per(10_000)
    end

    def set_thread_values
      Thread.current['tax_years'] = TaxHoldback.tax_years
      Thread.current['currency']  = params[:currency] || 'USD'
      Thread.current['year']      = params[:year] || Thread.current['tax_years'][0]
    end

    def tax_holdbacks
      TaxHoldback.by_currency(Thread.current['currency'], Thread.current['year'])
    end
  end

  index do
    div :class => 'scopes-content hide', 'data-currency' => Thread.current['currency'], 'data-year' => Thread.current['year'] do
      (Thread.current['tax_years'] + ['ALL']).to_json
    end

    total_holdback_fed = total_holdback_state = 0
    tax_holdback.each do |tax_report|
      total_holdback_fed += tax_report.holdback_fed.to_f
      total_holdback_state += tax_report.holdback_state.to_f
    end
    div :class => 'hide total-info', 'data-holdback-fed' => number_to_currency(total_holdback_fed, precision: 2),
        'data-holdback-state' => number_to_currency(total_holdback_state, precision: 2)

    column 'Investment' do |investment|
      link_to investment.name, admin_investment_path(investment.id)
    end
    column :currency
    column :year
    column :holdback_fed do |investment|
      number_to_currency(investment.holdback_fed, precision: 2)
    end
    column :holdback_state do |investment|
      number_to_currency(investment.holdback_state, precision: 2)
    end
  end
end
