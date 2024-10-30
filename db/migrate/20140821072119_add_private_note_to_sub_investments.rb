# frozen_string_literal: true

class AddPrivateNoteToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :private_note, :text
  end
end
