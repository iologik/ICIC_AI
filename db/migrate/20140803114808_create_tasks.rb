# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.date        :date
      t.text        :description
      t.string      :status
      t.references  :sub_investment

      t.timestamps
    end
  end
end
