# frozen_string_literal: true

class AddTransferFromToWithdraws < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :transfer_from_id, :integer
    add_index :withdraws, :transfer_from_id
  end
end
