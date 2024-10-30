# frozen_string_literal: true

class AddIcicCommittedCapitalToInvestment < ActiveRecord::Migration[6.0]
  def change
    add_column :investments, :icic_committed_capital, :decimal
  end
end
