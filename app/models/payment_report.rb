# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_reports
#
#  id                   :text
#  admin_user_id        :integer
#  due_date             :date
#  amount               :decimal(, )
#  currency             :string(255)
#  name                 :text
#  investment_source_id :integer
#
class PaymentReport < ApplicationRecord
  # prev/this/next month
  def self.due_next_month_cad
    PaymentReport.where(due_date: (Time.zone.today.at_beginning_of_month - 1.month)..(Time.zone.today.at_end_of_month + 1.month), currency: 'CAD')
  end

  # prev/this/next month
  def self.due_next_month_usd
    PaymentReport.where(due_date: (Time.zone.today.at_beginning_of_month - 1.month)..(Time.zone.today.at_end_of_month + 1.month), currency: 'USD')
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(admin_user_id amount currency due_date id investment_source_id name)
  end
end
