# frozen_string_literal: true

class ModifyMemoInInvestments < ActiveRecord::Migration[5.2]
  def change
    change_column :investments, :memo, :string, limit: 120
  end
end
