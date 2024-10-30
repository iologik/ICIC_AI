# frozen_string_literal: true

class AddCurrencyToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :currency, :string

    Payment.all.each do |payment|
      if payment.sub_investment
        payment.currency = payment.sub_investment.currency
        payment.save!
      end
    end
  end
end
