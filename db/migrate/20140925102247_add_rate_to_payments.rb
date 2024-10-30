# frozen_string_literal: true

class AddRateToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :rate, :decimal
  end
end
