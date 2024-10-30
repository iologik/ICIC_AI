# frozen_string_literal: true

class RemoveInvestmentKindFromSubInvestments < ActiveRecord::Migration[5.2]
  def change
    remove_column :sub_investments, :investment_kind_id
  end
end
