# frozen_string_literal: true

class AddDetailsInvestmentAmountsToSubInvestor < ActiveRecord::Migration[6.0]
  def change
    add_column :admin_users, :investment_amount_usd, :decimal
    add_column :admin_users, :investment_amount_cad, :decimal
  end
end
