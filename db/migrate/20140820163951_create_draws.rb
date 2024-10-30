# frozen_string_literal: true

class CreateDraws < ActiveRecord::Migration[5.2]
  def change
    create_table :draws do |t|
      t.decimal     :amount
      t.date        :date
      t.text        :description
      t.references  :investment

      t.timestamps
    end
  end
end
