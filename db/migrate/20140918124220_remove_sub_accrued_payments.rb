# frozen_string_literal: true

class RemoveSubAccruedPayments < ActiveRecord::Migration[5.2]
  def change
    drop_table :sub_accrued_payments
  end
end
