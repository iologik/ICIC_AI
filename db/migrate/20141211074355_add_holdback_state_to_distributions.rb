# frozen_string_literal: true

class AddHoldbackStateToDistributions < ActiveRecord::Migration[5.2]
  def change
    add_column :distributions, :holdback_state, :decimal, precision: 12, scale: 2
  end
end
