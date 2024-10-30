# frozen_string_literal: true

class AddStartDateToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :start_date, :date
  end
end
