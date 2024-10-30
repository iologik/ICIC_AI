# frozen_string_literal: true

ActiveAdmin.register InvestmentRetained do
  menu parent: 'Reports', label: 'Investment Interest Reserve'

  actions :all, except: %i(edit update new create destroy)

  config.sort_order = nil
  config.filters = false
  config.batch_actions = false
  config.paginate = false

  scope :with_retained, default: true

  controller do
    def index
      super do |format|
        format.pdf do
          investment_retaineds = BuildInvestmentRetainedsService.new.call(@investment_retaineds)
          send_data investment_retaineds.render, type: 'application/pdf', disposition: 'inline'
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
    cad_retained = usd_retained = 0
    InvestmentRetained.find_each do |r|
      cad_retained += r.retained if r.currency == 'CAD'
      usd_retained += r.retained if r.currency == 'USD'
    end
    div class: 'hide investment-cad-retained-total' do
      number_to_currency(cad_retained, precision: 2)
    end
    div class: 'hide investment-usd-retained-total' do
      number_to_currency(usd_retained, precision: 2)
    end

    column :name, sortable: :name do |o|
      link_to o.name, "/admin/investments/#{o.id}"
    end
    column 'Interest Reserve CAD' do |item|
      "#{number_to_currency(item.retained, precision: 2)} CAD" if item.currency == 'CAD'
    end
    column 'Interest Reserve USD' do |item|
      "#{number_to_currency(item.retained, precision: 2)} USD" if item.currency == 'USD'
    end
  end
end
