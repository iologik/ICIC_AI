# frozen_string_literal: true

class CreateLoanWithdraws < ActiveRecord::Migration[5.2]
  def change
    create_table :loan_withdraws do |t|
      t.references :loan
      t.float :amount
      t.date :due_date
      t.string :check_no
      t.string :type
      t.timestamps
    end
  end
end
