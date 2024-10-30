# frozen_string_literal: true

class AddInvestmentAmountTo < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_distributions, :investment_amount, :decimal
  end
end
