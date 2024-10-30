# frozen_string_literal: true

class AddCheckNoToSubDistribution < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_distributions, :check_no, :string
  end
end
