# frozen_string_literal: true

class GenerateSubInvestorAndInvestmentNamesForPayments < ActiveRecord::Migration[5.2]
  def change
    Payment.all.each(&:save)
  end
end
