# frozen_string_literal: true

class AlterPaidForPayments < ActiveRecord::Migration[5.2]
  def up
    Payment.all.each do |payment|
      unless payment.paid
        payment.paid = false
        payment.save
      end
    end

    change_column :payments, :paid, :boolean, default: false, null: false
  end

  def down
    change_column :payments, :paid, :boolean, default: nil
  end
end
