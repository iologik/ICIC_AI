# frozen_string_literal: true

class ChangeLimitOfRemoteAgreementUrlForSubInvestments < ActiveRecord::Migration[5.2]
  def change
    change_column :sub_investments, :remote_agreement_url, :string, limit: nil
  end
end
