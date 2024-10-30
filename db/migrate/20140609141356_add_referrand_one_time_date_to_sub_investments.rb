# frozen_string_literal: true

class AddReferrandOneTimeDateToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :referrand_one_time_date, :date
  end
end
