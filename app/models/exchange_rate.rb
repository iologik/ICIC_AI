# frozen_string_literal: true

# == Schema Information
#
# Table name: exchange_rates
#
#  id              :integer          not null, primary key
#  date            :date
#  usd_to_cad_rate :decimal(, )
#  cad_to_usd_rate :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class ExchangeRate < ApplicationRecord
  def self.exchange_date_by(date, from)
    @exchange_date_by ||= {}
    @exchange_date_by["#{date}-#{from}"] ||= ExchangeRate.where('date <= ?', date).order('date desc').first.try(:date)
  end

  def self.exchange_rate_by(date, from)
    @exchange_rate_by ||= {}
    @exchange_rate_by["#{date}-#{from}"] ||= begin
      field = if from == 'USD'
                'usd_to_cad_rate'
              else
                'cad_to_usd_rate'
              end
      ExchangeRate.where('date <= ?', date).order('date desc').first.try(field)
    end
  end

  def self.now_usd_to_cad_rate
    @now_usd_to_cad_rate ||= ExchangeRate.order('date desc').first.usd_to_cad_rate
  end

  def self.now_cad_to_usd_rate
    @now_cad_to_usd_rate ||= ExchangeRate.order('date desc').first.cad_to_usd_rate
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(cad_to_usd_rate created_at date id updated_at usd_to_cad_rate)
  end
end
