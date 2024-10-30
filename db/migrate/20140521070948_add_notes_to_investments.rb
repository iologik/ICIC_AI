# frozen_string_literal: true

class AddNotesToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :private_note, :text
  end
end
