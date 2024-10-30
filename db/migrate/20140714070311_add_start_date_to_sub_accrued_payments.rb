# frozen_string_literal: true

class AddStartDateToSubAccruedPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_accrued_payments, :start_date, :date
  end
end
