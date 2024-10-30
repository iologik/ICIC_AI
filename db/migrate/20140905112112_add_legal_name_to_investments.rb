# frozen_string_literal: true

class AddLegalNameToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :legal_name, :string
  end
end
