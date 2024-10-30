# frozen_string_literal: true

class CreateInvestmentStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :investment_statuses do |t|
      t.string :name
      t.timestamps
    end
  end
end
