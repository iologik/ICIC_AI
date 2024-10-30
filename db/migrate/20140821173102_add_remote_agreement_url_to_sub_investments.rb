# frozen_string_literal: true

class AddRemoteAgreementUrlToSubInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_investments, :remote_agreement_url, :string
  end
end
