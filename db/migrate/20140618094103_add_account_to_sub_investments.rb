# frozen_string_literal: true

class AddAccountToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :account_id, :integer
    add_index :sub_investments, :account_id
  end
end
