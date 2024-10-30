# frozen_string_literal: true

class AddDescriptionToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :description, :text
  end
end
