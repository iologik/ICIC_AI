# frozen_string_literal: true

class AddPaidToWithdraws < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :paid, :boolean, default: false
  end
end
