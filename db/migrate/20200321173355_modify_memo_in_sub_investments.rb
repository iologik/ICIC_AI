# frozen_string_literal: true

class ModifyMemoInSubInvestments < ActiveRecord::Migration[5.2]
  def change
    change_column :sub_investments, :memo, :string, limit: 120
  end
end
