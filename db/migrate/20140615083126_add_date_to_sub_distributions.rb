# frozen_string_literal: true

class AddDateToSubDistributions < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_distributions, :date, :date
  end
end
