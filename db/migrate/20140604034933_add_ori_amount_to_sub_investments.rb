# frozen_string_literal: true

class AddOriAmountToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :ori_amount, :decimal
  end
end
