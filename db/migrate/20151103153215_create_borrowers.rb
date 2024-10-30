# frozen_string_literal: true

class CreateBorrowers < ActiveRecord::Migration[5.2]
  def change
    create_table(:borrowers) do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :company

      t.timestamps
    end
  end
end
