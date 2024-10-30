# frozen_string_literal: true

class RemoveInvestmentSourceFromSubInvestments < ActiveRecord::Migration[5.2]
  def change
    remove_column :sub_investments, :investment_source_id
  end
end
