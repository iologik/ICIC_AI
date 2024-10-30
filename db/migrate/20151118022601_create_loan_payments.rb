# frozen_string_literal: true

class CreateLoanPayments < ActiveRecord::Migration[5.2]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :loan_payments do |t|
      t.references :loan
      t.references :borrower
      t.references :cash_call
      t.string :payment_kind
      t.date :due_date
      t.string :check_no
      t.string :memo
      t.boolean :paid, default: false
      t.decimal :amount, precision: 12, scale: 2
      t.date :start_date
      t.text :remark
      t.decimal :loan_amount, precision: 12, scale: 2
      t.string :currency
      t.decimal :rate, precision: 12, scale: 2

      t.timestamps
    end
  end
  # rubocop:enable Metrics/MethodLength
end
