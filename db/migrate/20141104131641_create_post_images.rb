# frozen_string_literal: true

class CreatePostImages < ActiveRecord::Migration[5.2]
  def change
    create_table :post_images do |t|
      t.string :file

      t.timestamps
    end
  end
end
