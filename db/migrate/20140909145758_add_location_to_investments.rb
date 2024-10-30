# frozen_string_literal: true

class AddLocationToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :location, :string
  end
end
