# frozen_string_literal: true

class AddTransferFromIdToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :transfer_from_id, :integer
    add_index :sub_investments, :transfer_from_id
  end
end
