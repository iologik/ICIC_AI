# frozen_string_literal: true

class DashboardThirdColumnCalculatorJob < ApplicationJob
  queue_as :default
  include ActionView::Helpers::NumberHelper

  def perform(*_args)
    # Do something later
    Variable.find_pair('usd_sum_amount').update(value: f(usd_sum_amount))
    Variable.find_pair('cad_sum_amount').update(value: f(cad_sum_amount))
  end

  def usd_sum_amount
    sum_amount 'USD'
  end

  def cad_sum_amount
    sum_amount 'CAD'
  end

  def sum_amount(currency)
    investment_balance = 0
    Investment.where(currency: currency).find_each do |investment|
      investment_balance += investment.amount
    end

    investment_balance
  end

  def f(val)
    number_to_currency(val, precision: 0)
  end
end
