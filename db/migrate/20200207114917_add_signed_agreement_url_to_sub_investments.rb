# frozen_string_literal: true

class AddSignedAgreementUrlToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :signed_agreement_url, :string
  end
end
