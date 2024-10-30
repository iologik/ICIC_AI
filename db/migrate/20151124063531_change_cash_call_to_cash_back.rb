# frozen_string_literal: true

class ChangeCashCallToCashBack < ActiveRecord::Migration[5.2]
  def up
    rename_column :loan_payments, :cash_call_id, :cash_back_id
  end
end
