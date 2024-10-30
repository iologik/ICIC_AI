# frozen_string_literal: true

class AddTypeToWithdraws < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :type, :string
  end
end
