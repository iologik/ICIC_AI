# frozen_string_literal: true

class AddFieldsFees < ActiveRecord::Migration[5.2]
  def change
    add_column :fees, :collected, :boolean, default: false
  end
end
