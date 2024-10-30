# frozen_string_literal: true

class AddNameToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :name, :string, default: ''
  end
end
