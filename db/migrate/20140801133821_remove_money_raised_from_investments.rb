# frozen_string_literal: true

class RemoveMoneyRaisedFromInvestments < ActiveRecord::Migration[5.2]
  def change
    remove_column :investments, :money_raised
  end
end
