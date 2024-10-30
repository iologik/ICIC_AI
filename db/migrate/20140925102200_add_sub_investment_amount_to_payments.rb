# frozen_string_literal: true

class AddSubInvestmentAmountToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :sub_investment_amount, :decimal
  end
end
