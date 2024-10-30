# frozen_string_literal: true

class AddNotifyInvestorToSubDistributions < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_distributions, :is_notify_investor, :boolean
  end
end
