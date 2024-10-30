# frozen_string_literal: true

class AddStatusToSubDistribution < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_distributions, :status, :string, default: 'Not sent'
  end
end
