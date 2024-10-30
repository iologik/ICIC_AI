# frozen_string_literal: true

class RemoveStartDateFromSubInvestments < ActiveRecord::Migration[5.2]
  def change
    remove_column :sub_investments, :start_date
    remove_column :sub_investments, :per_annum
    remove_column :sub_investments, :accrued_per_annum
  end
end
