# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string     :title, length: 1000
      t.text       :body
      t.references :investment

      t.timestamps
    end
  end
end
