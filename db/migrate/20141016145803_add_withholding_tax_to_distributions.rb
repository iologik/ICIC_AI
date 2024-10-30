# frozen_string_literal: true

class AddWithholdingTaxToDistributions < ActiveRecord::Migration[5.2]
  def change
    add_column :distributions, :withholding_tax, :decimal, precision: 12, scale: 2
  end
end
