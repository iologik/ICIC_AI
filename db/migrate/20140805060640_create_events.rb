# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.date        :date
      t.text        :description
      t.references  :sub_investment

      t.timestamps
    end
  end
end
