# frozen_string_literal: true

class AddPaybackInterestToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :payback_interest, :decimal
  end
end
