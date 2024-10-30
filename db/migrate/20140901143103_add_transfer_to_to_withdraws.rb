# frozen_string_literal: true

class AddTransferToToWithdraws < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :transfer_to_id, :integer
    add_index :withdraws, :transfer_to_id
  end
end
