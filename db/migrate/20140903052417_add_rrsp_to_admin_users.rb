# frozen_string_literal: true

class AddRrspToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :rrsp, :string
    add_column :admin_users, :rif, :string
    add_column :admin_users, :lif, :string
    add_column :admin_users, :lira, :string
  end
end
