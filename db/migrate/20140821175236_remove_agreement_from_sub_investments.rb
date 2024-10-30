# frozen_string_literal: true

class RemoveAgreementFromSubInvestments < ActiveRecord::Migration[5.2]
  def change
    remove_column :sub_investments, :agreement
  end
end
