# frozen_string_literal: true

class AddInvestmentAmountToAdminUser < ActiveRecord::Migration[6.0]
  def change
    add_column :admin_users, :investment_amount, :decimal, precision: 12, scale: 2
  end
end
