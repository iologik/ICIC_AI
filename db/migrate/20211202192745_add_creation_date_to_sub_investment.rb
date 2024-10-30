# frozen_string_literal: true

class AddCreationDateToSubInvestment < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_investments, :creation_date, :date
  end
end
