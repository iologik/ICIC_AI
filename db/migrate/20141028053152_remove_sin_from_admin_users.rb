# frozen_string_literal: true

class RemoveSinFromAdminUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :admin_users, :sin
  end
end
