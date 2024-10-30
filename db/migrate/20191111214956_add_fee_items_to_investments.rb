# frozen_string_literal: true

class AddFeeItemsToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :fee_type, :string
    add_column :investments, :fee_amount, :decimal
  end
end
