# frozen_string_literal: true

class CreateSubInvestorRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :sub_investor_relationships do |t|
      t.references :admin_user
      t.integer    :account_id

      t.timestamps
    end

    add_index :sub_investor_relationships, :account_id
  end
end
