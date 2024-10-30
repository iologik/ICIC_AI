# frozen_string_literal: true

class AddIsResendStatementToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :is_resend_statement, :boolean
  end
end
