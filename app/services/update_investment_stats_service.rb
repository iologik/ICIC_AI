# frozen_string_literal: true

class UpdateInvestmentStatsService < BaseService
  attr_accessor :investment

  def call(investment_id)
    return unless Investment.exists?(investment_id)

    @investment = Investment.find(investment_id)
    @investment.adjust_amounts

    update_sub_investments_stats
    update_distribution_stats
    update_other_stats
    update_accrued_retained_payable

    @investment.save
  end

  # rubocop:disable Metrics/AbcSize
  def update_sub_investments_stats
    investment.sub_amount_total          = sub_invests.sum(&:ownership_amount)
    investment.sub_ownership_percent_sum = sub_ownership_percent_sum
    investment.sub_per_annum_sum         = sub_invests.sum { |subi| subi.per_annum * subi.ownership_amount }
    investment.sub_accrued_percent_sum   = sub_invests.sum { |subi| subi.accrued_per_annum * subi.ownership_amount }
    investment.sub_retained_percent_sum  = sub_invests.sum { |subi| subi.retained_per_annum * subi.ownership_amount }
  end
  # rubocop:enable Metrics/AbcSize

  def sub_invests
    investment.sub_investments
  end

  def sub_ownership_percent_sum
    investment.amount.zero? ? 0 : sub_invests.sum { |subi| subi.ownership_amount / investment.amount * 100 }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def update_distribution_stats
    distributions = investment.distributions

    investment.distrib_return_of_capital = distributions.sum(&:return_of_capital)
    investment.distrib_withholding_tax   = distributions.sum(&:withholding_tax)
    investment.distrib_holdback_state    = distributions.sum { |distrib| (distrib.holdback_state || 0) }
    investment.distrib_gross_profit      = distributions.sum(&:gross_profit)
    investment.distrib_cash_reserve      = distributions.sum { |distrib| (distrib.cash_reserve || 0) }
    investment.distrib_net_cash          = distributions.sum(&:net_cash)
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def update_other_stats
    investment.draw_amount               = investment.draws.sum(&:amount)
    investment.money_raised_amount       = investment.money_raised
    investment.gross_profit_total_amount = investment.gross_profit_total
    investment.all_paid_payments_amount  = investment.all_paid_payments
    investment.sub_balance_amount        = investment.sub_balance
    investment.net_income_amount         = investment.net_income
  end
  # rubocop:enable Metrics/AbcSize

  def update_accrued_retained_payable
    investment.accrued_payable_amount  = investment.accrued_payable
    investment.retained_payable_amount = investment.retained_payable
  end
end
