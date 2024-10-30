# frozen_string_literal: true

class AddYearPaidToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :year_paid, :decimal
  end
end
