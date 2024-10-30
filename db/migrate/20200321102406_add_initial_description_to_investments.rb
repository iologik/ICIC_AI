# frozen_string_literal: true

class AddInitialDescriptionToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :initial_description, :text
  end
end
