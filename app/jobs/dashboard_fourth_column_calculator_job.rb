# frozen_string_literal: true

class DashboardFourthColumnCalculatorJob < ApplicationJob
  queue_as :default
  include ActionView::Helpers::NumberHelper

  def perform(*_args)
    # Do something later
    Variable.find_pair('usd_sum_this_year').update(value: f(usd_sum_this_year))
    Variable.find_pair('cad_sum_this_year').update(value: f(cad_sum_this_year))
    Variable.find_pair('usd_sum_until_this_year').update(value: f(usd_sum_until_this_year))
    Variable.find_pair('cad_sum_until_this_year').update(value: f(cad_sum_until_this_year))
  end

  def usd_sum_this_year
    Investment.where("currency = 'USD'").sum do |invest|
      invest.sub_balance_between(Time.zone.today.at_beginning_of_year, Time.zone.today)
    end
  end

  def cad_sum_this_year
    Investment.where("currency = 'CAD'").sum do |invest|
      invest.sub_balance_between(Time.zone.today.at_beginning_of_year, Time.zone.today)
    end
  end

  def usd_sum_until_this_year
    Investment.where("currency = 'USD'").sum do |invest|
      invest.sub_balance_by_date((Time.zone.today - 1.year).at_end_of_year)
    end
  end

  def cad_sum_until_this_year
    Investment.where("currency = 'CAD'").sum do |invest|
      invest.sub_balance_by_date((Time.zone.today - 1.year).at_end_of_year)
    end
  end

  def f(val)
    number_to_currency(val, precision: 0)
  end
end
