# frozen_string_literal: true

class AddEmailSubInvestorToUpdates < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :email_sub_investor, :boolean
  end
end
