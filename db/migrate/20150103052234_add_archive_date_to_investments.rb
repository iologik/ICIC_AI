# frozen_string_literal: true

class AddArchiveDateToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :archive_date, :date
  end
end
