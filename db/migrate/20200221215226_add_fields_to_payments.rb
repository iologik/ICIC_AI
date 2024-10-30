# frozen_string_literal: true

class AddFieldsToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :sub_investor_name, :string
    add_column :payments, :investment_name, :string
  end
end
