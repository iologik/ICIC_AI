# frozen_string_literal: true

class AddWithdrawToFees < ActiveRecord::Migration[5.2]
  def change
    add_reference :fees, :withdraw
  end
end
