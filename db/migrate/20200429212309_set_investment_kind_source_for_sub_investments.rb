# frozen_string_literal: true

class SetInvestmentKindSourceForSubInvestments < ActiveRecord::Migration[5.2]
  def change
    SubInvestment.all.each(&:save)
  end
end
