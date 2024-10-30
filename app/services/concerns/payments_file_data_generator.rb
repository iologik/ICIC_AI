# frozen_string_literal: true

module PaymentsFileDataGenerator
  HEADERS = ['Sub Investor Name', 'Investment Name', 'Payment Type', 'Amount', 'Currency', 'Due Date', 'Paid Date', 'Status', 'Check No'].freeze
  FIELDS = [
    :sub_investor_name,
    'investments.name',
    :payment_kind,
    :amount,
    'sub_investments.currency',
    :due_date,
    :paid_date,
    :paid,
    :check_no,
  ].freeze

  def generate_file_data(payments)
    [[HEADERS, *adjust(lines(payments))], *sums(payments, 'CAD', 'USD')]
  end

  private

  def adjust(lines)
    lines.map do |line|
      [line[0], line[1], line[2], line[3], line[4], (line[5]).to_s, (line[6]).to_s, line[7] ? 'Paid' : 'Pending', line[8]]
    end
  end

  def lines(payments)
    payments
      .joins(sub_investment: :investment)
      .pluck(*FIELDS)
  end

  def sums(payments, *currencies)
    payments
      .group(:currency)
      .sum(:amount)
      .values_at(*currencies)
      .map { |sum| sum || 0 }
  end
end
