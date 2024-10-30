# frozen_string_literal: true

class AddAddressToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :address, :string
  end
end
