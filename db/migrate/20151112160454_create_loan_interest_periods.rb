# frozen_string_literal: true

class CreateLoanInterestPeriods < ActiveRecord::Migration[5.2]
  def change
    create_table :loan_interest_periods do |t|
      t.date        :effect_date
      t.decimal     :per_annum
      t.references  :loan

      t.timestamps
    end
  end
end
