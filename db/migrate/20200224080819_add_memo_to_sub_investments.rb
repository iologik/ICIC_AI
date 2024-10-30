# frozen_string_literal: true

class AddMemoToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :memo, :text
  end
end
