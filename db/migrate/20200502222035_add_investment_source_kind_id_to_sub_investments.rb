# frozen_string_literal: true

class AddInvestmentSourceKindIdToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :sub_investment_source_id, :string
    add_column :sub_investments, :sub_investment_kind_id, :string
  end
end
