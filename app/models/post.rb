# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  body               :text
#  investment_id      :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  email_sub_investor :boolean
#
class Post < ApplicationRecord
  # attr_accessible :title, :body, :investment_id
  after_initialize :set_email_sub_investor
  after_save :send_email_sub_investor

  belongs_to :investment

  private

  def set_email_sub_investor
    false
  end

  def send_email_sub_investor
    return unless email_sub_investor && saved_changes.key?('body')

    sub_investor_ids = investment.sub_investments.pluck(:admin_user_id)

    sub_investor_ids.each do |id|
      UpdateMailer.email_sub_investor(self, AdminUser.find(id)).deliver
    end
  end
end
