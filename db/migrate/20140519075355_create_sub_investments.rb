# frozen_string_literal: true

class CreateSubInvestments < ActiveRecord::Migration[5.2]
  # rubocop:disable Metrics/MethodLength
  def change
    create_sub_investments_table
    add_index :sub_investments, :admin_user_id
    add_index :sub_investments, :investment_id
  end

  def create_sub_investments_table
    create_table :sub_investments do |t|
      t.integer :admin_user_id
      t.integer :investment_id
      t.string :scheduled
      t.integer :months
      t.float :amount
      t.string :currency
      t.float :per_annum
      t.float :accrued_per_annum
      t.date :start_date
      t.integer :refferand_user_id
      t.float :refferand_percent
      t.float :one_time_amount
      t.string :status
      t.timestamps
    end
  end
  # rubocop:enable Metrics/MethodLength
end
