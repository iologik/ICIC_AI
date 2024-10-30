# frozen_string_literal: true

class AddInvestmentStatusToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    remove_column :sub_investments, :status
    add_column :sub_investments, :investment_status_id, :integer

    # add_index(table_name, column_name)
    add_index :sub_investments, :investment_status_id
  end
end
