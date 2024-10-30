# frozen_string_literal: true

class AlterStatusForSubInvestments < ActiveRecord::Migration[5.2]
  def change
    change_column :sub_investments, :status, :string, default: 'Active'

    # SubInvestment.all.each do |invest|
    #   if invest.amount == 0
    #     invest.status = "Archive"
    #   else
    #     invest.status = "Active"
    #   end
    #   invest.save
    # end
  end
end
