# frozen_string_literal: true

class AddRetainedPerAnnumToInterestPeriods < ActiveRecord::Migration[5.2]
  def change
    add_column :interest_periods, :retained_per_annum, :decimal
  end
end
