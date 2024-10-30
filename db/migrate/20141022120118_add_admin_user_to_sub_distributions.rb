# frozen_string_literal: true

class AddAdminUserToSubDistributions < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_distributions, :admin_user_id, :integer
  end
end
