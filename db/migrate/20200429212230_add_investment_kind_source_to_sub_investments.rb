# frozen_string_literal: true

class AddInvestmentKindSourceToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_reference :sub_investments, :investment_kind, foreign_key: true
    add_reference :sub_investments, :investment_source, foreign_key: true
  end
end
