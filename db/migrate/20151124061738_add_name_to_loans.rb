# frozen_string_literal: true

class AddNameToLoans < ActiveRecord::Migration[5.2]
  def change
    add_column :loans, :name, :string
  end
end
