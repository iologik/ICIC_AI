# frozen_string_literal: true

class CreateWithdraws < ActiveRecord::Migration[5.2]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :withdraws do |t|
      t.integer :admin_user_id
      t.integer :sub_investment_id
      t.float :amount
      t.date :due_date
      t.string :check_no
      t.string :status
      t.timestamps
    end
    add_index :withdraws, :admin_user_id
    add_index :withdraws, :sub_investment_id
  end
  # rubocop:enable Metrics/MethodLength
end
