# frozen_string_literal: true

class AddPaidDateToWithdraws < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :paid_date, :date
  end
end
