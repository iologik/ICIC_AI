# frozen_string_literal: true

class SetSubInvestmentSourceKind < ActiveRecord::Migration[5.2]
  def change
    SubInvestment.all.each(&:save)
  end
end
