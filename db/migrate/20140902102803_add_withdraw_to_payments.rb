# frozen_string_literal: true

class AddWithdrawToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :withdraw_id, :integer
    add_index :payments, :withdraw_id
  end
end
