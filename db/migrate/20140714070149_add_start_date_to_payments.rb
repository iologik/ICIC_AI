# frozen_string_literal: true

class AddStartDateToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :start_date, :date
  end
end
