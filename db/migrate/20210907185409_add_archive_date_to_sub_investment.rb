# frozen_string_literal: true

class AddArchiveDateToSubInvestment < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_investments, :archive_date, :date
  end
end
