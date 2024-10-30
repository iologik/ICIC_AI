# frozen_string_literal: true

class ChangeRemarkColumnOnPayments < ActiveRecord::Migration[5.2]
  def up
    change_column :payments, :remark, :text
  end

  def down
    change_column :payments, :remark, :text
  end
end
