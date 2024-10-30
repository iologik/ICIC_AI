# frozen_string_literal: true

class AddCurrentAccruedRetainedToSubInvestments < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_investments, :current_accrued_amount, :decimal
    add_column :sub_investments, :current_retained_amount, :decimal
  end
end
