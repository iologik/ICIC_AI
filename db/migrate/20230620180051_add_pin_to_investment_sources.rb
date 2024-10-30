# frozen_string_literal: true

class AddPinToInvestmentSources < ActiveRecord::Migration[6.0]
  def change
    add_column :investment_sources, :pin, :string
  end
end
