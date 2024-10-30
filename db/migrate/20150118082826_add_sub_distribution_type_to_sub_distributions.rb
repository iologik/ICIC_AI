# frozen_string_literal: true

class AddSubDistributionTypeToSubDistributions < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_distributions, :sub_distribution_type, :string
  end
end
