# frozen_string_literal: true

class AddNotifyToInvestorToWithdraws < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :is_notify_to_investor, :boolean
  end
end
