# frozen_string_literal: true

class AddPinToAdminUser < ActiveRecord::Migration[6.0]
  def change
    add_column :admin_users, :pin, :string
  end
end
