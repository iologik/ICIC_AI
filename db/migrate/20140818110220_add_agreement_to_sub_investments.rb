# frozen_string_literal: true

class AddAgreementToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :agreement, :string
  end
end
