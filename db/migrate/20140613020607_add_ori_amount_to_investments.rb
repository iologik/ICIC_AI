# frozen_string_literal: true

class AddOriAmountToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :ori_amount, :decimal
  end
end
