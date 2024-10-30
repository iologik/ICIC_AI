# frozen_string_literal: true

class AddProfitToIncomes < ActiveRecord::Migration[5.2]
  def change
    add_column :incomes, :profit, :decimal
  end
end
