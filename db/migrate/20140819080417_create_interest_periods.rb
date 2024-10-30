# frozen_string_literal: true

class CreateInterestPeriods < ActiveRecord::Migration[5.2]
  def change
    create_table :interest_periods do |t|
      t.date        :effect_date
      t.decimal     :per_annum
      t.decimal     :accrued_per_annum
      t.references  :sub_investment

      t.timestamps
    end
  end
end
