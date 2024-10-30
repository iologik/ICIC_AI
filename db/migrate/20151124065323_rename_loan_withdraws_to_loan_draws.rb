# frozen_string_literal: true

class RenameLoanWithdrawsToLoanDraws < ActiveRecord::Migration[5.2]
  def change
    rename_table :loan_withdraws, :loan_draws
  end
end
