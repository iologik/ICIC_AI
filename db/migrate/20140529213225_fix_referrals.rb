# frozen_string_literal: true

class FixReferrals < ActiveRecord::Migration[5.2]
  def change
    remove_column :sub_investments, :refferand_user_id
    remove_column :sub_investments, :refferand_percent
    remove_column :sub_investments, :one_time_amount

    add_column :sub_investments, :referrand_user_id, :integer
    add_column :sub_investments, :referrand_percent, :float
    add_column :sub_investments, :referrand_one_time_amount, :float
    add_column :sub_investments, :referrand_amount, :float
    add_column :sub_investments, :referrand_scheduled, :string
  end
end
