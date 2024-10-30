# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_payments_table
    add_index :payments, :sub_investment_id
    add_index :payments, :admin_user_id
  end

  def create_payments_table
    create_table :payments do |t|
      t.integer :sub_investment_id
      t.integer :admin_user_id
      t.date :due_date
      t.float :amount
      t.string :memo, :payment_kind
      t.string :check_no
      t.boolean :paid

      t.timestamps
    end
  end
end
