# frozen_string_literal: true

class AddStatusToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :status, :string
  end
end
