# frozen_string_literal: true

class AddMemoToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :memo, :text
  end
end
