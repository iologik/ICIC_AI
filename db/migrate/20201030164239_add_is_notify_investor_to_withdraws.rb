# frozen_string_literal: true

class AddIsNotifyInvestorToWithdraws < ActiveRecord::Migration[6.0]
  def change
    add_column :withdraws, :is_notify_investor, :boolean
  end
end
