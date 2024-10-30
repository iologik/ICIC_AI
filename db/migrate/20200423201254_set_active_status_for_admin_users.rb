# frozen_string_literal: true

class SetActiveStatusForAdminUsers < ActiveRecord::Migration[5.2]
  def change
    AdminUser.update(status: 'active')
  end
end
