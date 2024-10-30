# frozen_string_literal: true

class AddPostalCodeToInvestments < ActiveRecord::Migration[6.0]
  def change
    add_column :investments, :postal_code, :string
  end
end
