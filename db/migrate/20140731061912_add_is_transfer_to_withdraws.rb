# frozen_string_literal: true

class AddIsTransferToWithdraws < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :is_transfer, :boolean, default: false
  end
end
