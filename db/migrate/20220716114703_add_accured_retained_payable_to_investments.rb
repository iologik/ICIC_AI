# frozen_string_literal: true

# Add accrued and retained payable amount to investments
class AddAccuredRetainedPayableToInvestments < ActiveRecord::Migration[6.0]
  def change
    add_column :investments, :accrued_payable_amount, :decimal
    add_column :investments, :retained_payable_amount, :decimal
  end
end
