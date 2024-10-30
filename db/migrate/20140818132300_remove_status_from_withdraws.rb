# frozen_string_literal: true

class RemoveStatusFromWithdraws < ActiveRecord::Migration[5.2]
  def up
    remove_column :withdraws, :status
  end

  def down
    add_column :withdraws, :status, :string
  end
end
