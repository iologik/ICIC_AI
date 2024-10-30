# frozen_string_literal: true

class CreateSubDistributions < ActiveRecord::Migration[5.2]
  def change
    create_table :sub_distributions do |t|
      t.references :distribution
      t.references :sub_investment
      t.decimal :sub_investment_amount
      t.decimal :percent # sub_investment_amount / investment_ori_amount
      t.decimal :amount # distribution_amount * percent

      t.timestamps
    end
  end
end
