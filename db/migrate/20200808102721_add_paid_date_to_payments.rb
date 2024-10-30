# frozen_string_literal: true

class AddPaidDateToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :paid_date, :date
  end
end
