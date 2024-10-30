# frozen_string_literal: true

class AddCompanyNameToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :company_name, :string
  end
end
