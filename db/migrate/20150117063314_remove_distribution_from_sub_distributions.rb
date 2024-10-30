# frozen_string_literal: true

class RemoveDistributionFromSubDistributions < ActiveRecord::Migration[5.2]
  def change
    remove_column :sub_distributions, :distribution_id
    remove_column :sub_distributions, :sub_investment_amount
    remove_column :sub_distributions, :percent
    remove_column :sub_distributions, :status
    remove_column :sub_distributions, :investment_amount
  end
end
