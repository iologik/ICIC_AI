# frozen_string_literal: true

class CreateSubAccruedPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :sub_accrued_payments do |t|
      t.date        :due_date
      t.references  :sub_investment
      t.decimal     :amount
      t.references  :admin_user
      t.references  :payment
      t.boolean     :paid, default: false

      t.timestamps
    end
  end
end
