# frozen_string_literal: true

ActiveAdmin.register InvestmentSubDistribution do
  menu parent: 'Reports'

  actions :all, except: %i(edit update new create destroy)

  config.sort_order = nil
  config.filters = false
  config.batch_actions = false
  config.paginate = false

  scope :with_sub_distribution, default: true

  controller do
    def index
      super do |format|
        format.pdf do
          investment_sub_distributions = BuildInvestmentSubDistributionsService.new.call(@investment_sub_distributions)
          send_data investment_sub_distributions.render, type: 'application/pdf', disposition: 'inline'
          # send_data renders the pdf on the client side rather than saving it on the server filesystem.
          # Inline disposition renders it in the browser rather than making it a file download.
        end
      end
    end
  end

  index do
    usd_sub_distribution_amount = cad_sub_distribution_amount = 0
    investment_sub_distributions.each do |r|
      usd_sub_distribution_amount += r.sub_distribution_amount if r.currency == 'USD'
      cad_sub_distribution_amount += r.sub_distribution_amount if r.currency == 'CAD'
    end
    div class: 'hide usd_sub_distribution_amount' do
      number_to_currency(usd_sub_distribution_amount, precision: 2)
    end
    div class: 'hide cad_sub_distribution_amount' do
      number_to_currency(cad_sub_distribution_amount, precision: 2)
    end

    column :name, sortable: :name do |o|
      link_to o.name, "/admin/investments/#{o.id}"
    end
    column 'Sub Distribution CAD' do |item|
      "#{number_to_currency(item.sub_distribution_amount, precision: 2)} CAD" if item.currency == 'CAD'
    end
    column 'Sub Distribution USD' do |item|
      "#{number_to_currency(item.sub_distribution_amount, precision: 2)} USD" if item.currency == 'USD'
    end
  end
end
