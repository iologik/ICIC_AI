# frozen_string_literal: true

# == Schema Information
#
# Table name: investment_sources
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  pin        :string
#  priority   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class InvestmentSource < ApplicationRecord
  has_many :investments, dependent: :destroy
  has_many :payments, through: :investments

  validates :name, presence: true
  # rubocop:disable Rails/I18nLocaleTexts
  validates :pin, length: { maximum: 20 }, format: { with: /\A[A-Za-z0-9]*\z/, message: 'only allow letters and numbers' }
  # rubocop:enable Rails/I18nLocaleTexts

  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :priority, uniqueness: true
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  default_scope do
    ordered_investment_sources
  end

  def self.ordered_investment_sources
    name_order = [
      'Innovation Capital Investment Corp.',
      'Van Haren Investment Corp.',
      'Innovation Capital Investment USA Inc.',
      'Imor',
      'RRSP',
      'ICIC',
      'ICI,USA Inc',
    ]

    order_sql = 'CASE'
    name_order.each_with_index do |name, i|
      order_sql += " WHEN name='#{name}' THEN '#{i + 1}'"
    end
    order_sql += ' END'

    sanitized_sql = ActionController::Base.helpers.sanitize(order_sql)
    order(Arel.sql(sanitized_sql))
  end

  def self.imor
    @imor ||= InvestmentSource.where(name: 'Registered Saving Plans').first_or_create
  end

  def self.default_icic
    @default_icic ||= InvestmentSource.where(name: 'Innovation Capital Investment Corp.').first_or_create
  end

  def self.imor_investment_ids
    imor.investments.map(&:id).join(',')
  end

  def imor?
    self == InvestmentSource.imor
  end

  def self.ransackable_associations(_auth_object = nil)
    %w(investments payments)
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(created_at id name pin priority updated_at)
  end
end
