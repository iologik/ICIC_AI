# frozen_string_literal: true

# Add origin and target amount to transfer
class AddAmountTimeStampToSubDistribution < ActiveRecord::Migration[6.1]
  def change
    add_column :sub_distributions, :origin_amount, :decimal
    add_column :sub_distributions, :target_amount, :decimal
  end
end
