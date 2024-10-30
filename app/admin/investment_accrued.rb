# frozen_string_literal: true

ActiveAdmin.register InvestmentAccrued do
  menu parent: 'Reports'

  actions :all, except: %i(edit update new create destroy)

  config.sort_order = nil
  config.filters = false
  config.batch_actions = false
  config.paginate = true

  scope :with_accrued, default: true

  controller do
    def index
      super do |format|
        format.pdf do
          send_data BuildInvestmentAccruedsService.new.call(@investment_accrueds).render, type: 'application/pdf',
                                                                                          disposition: 'inline'
          # send_data renders the pdf on the client side rather than saving it on the server filesystem.
          # Inline disposition renders it in the browser rather than making it a file download.
        end
      end
    end

    private

    def save_search_criteria
      session[:payment_index_url] = request.original_url
    end
  end

  index do
    cad_accrued = usd_accrued = 0
    investment_accrueds.each do |r|
      cad_accrued += r.accrued if r.currency == 'CAD'
      usd_accrued += r.accrued if r.currency == 'USD'
    end
    div class: 'hide investment-cad-accrued-total' do
      number_to_currency(cad_accrued, precision: 2)
    end
    div class: 'hide investment-usd-accrued-total' do
      number_to_currency(usd_accrued, precision: 2)
    end

    column :name, sortable: :name do |o|
      link_to o.name, "/admin/investments/#{o.id}"
    end
    column 'Accrued CAD' do |item|
      "#{number_to_currency(item.accrued, precision: 2)} CAD" if item.currency == 'CAD'
    end
    column 'Accrued USD' do |item|
      "#{number_to_currency(item.accrued, precision: 2)} USD" if item.currency == 'USD'
    end
  end
end
