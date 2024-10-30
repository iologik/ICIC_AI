# frozen_string_literal: true

class DashboardSecondColumnCalculatorJob < ApplicationJob
  queue_as :default
  include ActionView::Helpers::NumberHelper

  def perform(*_args)
    # Do something later
    initializer
    calculate_sum_payable
    calculate_sum_until_now
  end

  def initializer
    @investments_by_currency_accrued = {
      'USD' => InvestmentAccrued.where(currency: 'USD'),
      'CAD' => InvestmentAccrued.where(currency: 'CAD'),
    }

    @investments_by_currency_retained = {
      'USD' => InvestmentRetained.where(currency: 'USD'),
      'CAD' => InvestmentRetained.where(currency: 'CAD'),
    }
  end

  def calculate_sum_payable
    Variable.find_pair('usd_accrued_sum_payable_in_future').update(value: f(usd_accrued_sum_payable_in_future))
    Variable.find_pair('cad_accrued_sum_payable_in_future').update(value: f(cad_accrued_sum_payable_in_future))
    Variable.find_pair('usd_retained_sum_payable_in_future').update(value: f(usd_retained_sum_payable_in_future))
    Variable.find_pair('cad_retained_sum_payable_in_future').update(value: f(cad_retained_sum_payable_in_future))
  end

  def calculate_sum_until_now
    Variable.find_pair('usd_accrued_sum_until_now').update(value: f(usd_accrued_sum_until_now))
    Variable.find_pair('cad_accrued_sum_until_now').update(value: f(cad_accrued_sum_until_now))
    Variable.find_pair('usd_retained_sum_until_now').update(value: f(usd_retained_sum_until_now))
    Variable.find_pair('cad_retained_sum_until_now').update(value: f(cad_retained_sum_until_now))
  end

  def usd_accrued_sum_payable_in_future
    accrued_sum_payable_in_future 'USD'
  end

  def cad_accrued_sum_payable_in_future
    accrued_sum_payable_in_future 'CAD'
  end

  def accrued_sum_payable_in_future(currency)
    investment_accrued = 0
    @investments_by_currency_accrued[currency].each do |investment|
      investment_accrued += (investment.accrued_payable - investment.accrued_until_this_year) if investment.accrued_payable.positive?
    end

    investment_accrued
  end

  def usd_retained_sum_payable_in_future
    retained_sum_payable_in_future 'USD'
  end

  def cad_retained_sum_payable_in_future
    retained_sum_payable_in_future 'CAD'
  end

  def retained_sum_payable_in_future(currency)
    investment_retained = 0
    @investments_by_currency_retained[currency].each do |investment|
      investment_retained += (investment.retained_payable - investment.retained_until_this_year) if investment.retained_payable.positive?
    end

    investment_retained
  end

  def usd_accrued_sum_until_now
    accrued_sum_until_now 'USD'
  end

  def cad_accrued_sum_until_now
    accrued_sum_until_now 'CAD'
  end

  def accrued_sum_until_now(currency)
    investment_accrued = 0
    @investments_by_currency_accrued[currency].each do |investment|
      investment_accrued += investment.accrued_until_this_year
    end

    investment_accrued
  end

  def usd_retained_sum_until_now
    retained_sum_until_now 'USD'
  end

  def cad_retained_sum_until_now
    retained_sum_until_now 'CAD'
  end

  def retained_sum_until_now(currency)
    investment_retained = 0
    @investments_by_currency_retained[currency].each do |investment|
      investment_retained += investment.retained_until_this_year
    end

    investment_retained
  end

  def f(val)
    number_to_currency(val, precision: 0)
  end
end
