# frozen_string_literal: true

class CreateVariables < ActiveRecord::Migration[6.0]
  def change
    create_table :variables do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
