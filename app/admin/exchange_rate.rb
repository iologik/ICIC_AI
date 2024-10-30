# frozen_string_literal: true

ActiveAdmin.register ExchangeRate do
  menu parent: 'Reference Tables'

  config.sort_order = 'date_asc'
  permit_params :date, :usd_to_cad_rate, :cad_to_usd_rate

  filter :date
  filter :usd_to_cad_rate
  filter :cad_to_usd_rate

  index do
    div class: 'exchange-rate' do
      label 'Exchange Rate'
      input value: Investment.latest_rate, disabled: true
    end

    column :id do |item|
      link_to item.id, admin_exchange_rate_path(item.id)
    end
    column :date
    column :usd_to_cad_rate
    column :cad_to_usd_rate
    column :created_at
    column :updated_at
  end
end
