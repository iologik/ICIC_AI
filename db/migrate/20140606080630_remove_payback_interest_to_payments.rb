# frozen_string_literal: true

class RemovePaybackInterestToPayments < ActiveRecord::Migration[5.2]
  def change
    remove_column :payments, :payback_interest
  end
end
