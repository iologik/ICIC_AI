# frozen_string_literal: true

class AddNotifyInvestorToSubInvestment < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_investments, :is_notify_investor, :boolean
  end
end
