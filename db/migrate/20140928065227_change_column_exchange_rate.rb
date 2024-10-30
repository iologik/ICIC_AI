# frozen_string_literal: true

class ChangeColumnExchangeRate < ActiveRecord::Migration[5.2]
  def up
    change_table :sub_investments do |t|
      t.change :exchange_rate, :decimal
    end
  end

  def down; end
end
