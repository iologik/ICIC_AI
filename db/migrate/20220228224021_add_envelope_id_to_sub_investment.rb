# frozen_string_literal: true

class AddEnvelopeIdToSubInvestment < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_investments, :envelope_id, :string
  end
end
