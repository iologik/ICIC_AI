# frozen_string_literal: true

class DashboardFirstColumnCalculatorJob < ApplicationJob
  queue_as :default
  include ActionView::Helpers::NumberHelper

  def perform(*_args)
    usd_amount, cad_amount = compute_amounts
    Variable.find_pair('usd_gain_on_subs').update(value: f(usd_amount))
    Variable.find_pair('cad_on_icic').update(value: f(cad_amount))
    Variable.find_pair('cad_gain_on_icic').update(value: f(cad_gain_on_icic))
    # Do something later
  end

  # rubocop:disable Metrics/AbcSize
  def compute_amounts
    sub_investments = SubInvestment.joins(:investment)
                                   .where('sub_investments.currency != investments.currency and sub_investments.amount != 0')
                                   .select('sub_investments.*')
    usd_amount = cad_amount = 0
    sub_investments.each do |sub_investment|
      if sub_investment.currency == 'CAD'
        usd_amount += sub_investment.ownership_amount - (sub_investment.amount * (ExchangeRate.exchange_rate_by(Time.zone.today, 'CAD') || 1))
      else
        cad_amount += sub_investment.ownership_amount - (sub_investment.amount * (ExchangeRate.exchange_rate_by(Time.zone.today, 'USD') || 1))
      end
    end

    [usd_amount, cad_amount]
  end
  # rubocop:enable Metrics/AbcSize

  def cad_gain_on_icic
    cad_amount = 0
    Investment.where(currency: 'USD').find_each do |invest|
      balance = invest.amount - invest.money_raised
      next if balance.negative?

      offset_rate = (ExchangeRate.exchange_rate_by(Time.zone.today, invest.currency) || 1) - (invest.exchange_rate || 1)
      amount = balance * offset_rate
      cad_amount += amount
    end

    cad_amount
  end

  def f(val)
    number_to_currency(val, precision: 0)
  end
end
