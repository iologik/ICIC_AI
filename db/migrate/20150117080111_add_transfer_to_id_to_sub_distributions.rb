# frozen_string_literal: true

class AddTransferToIdToSubDistributions < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_distributions, :transfer_to_id, :integer
    add_index :sub_distributions, :transfer_to_id
  end
end
