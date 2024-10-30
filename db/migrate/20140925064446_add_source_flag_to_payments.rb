# frozen_string_literal: true

class AddSourceFlagToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :source_flag, :string
  end
end
