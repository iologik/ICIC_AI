# frozen_string_literal: true

class AddRemarkToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :remark, :string, limit: 1000
  end
end
