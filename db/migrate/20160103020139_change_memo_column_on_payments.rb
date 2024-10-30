# frozen_string_literal: true

class ChangeMemoColumnOnPayments < ActiveRecord::Migration[5.2]
  def up
    change_column :payments, :memo, :text
  end

  def down
    change_column :payments, :memo, :string
  end
end
