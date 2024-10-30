# frozen_string_literal: true

class AddInitialDescriptionToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :initial_description, :text
  end
end
