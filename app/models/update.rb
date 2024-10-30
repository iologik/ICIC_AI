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
class Update < Post
  def self.latest_updates_by_user(user)
    get_updates(user)
  end

  def self.all_updates
    user = Thread.current['user']
    get_updates(user)
  end

  def self.get_updates(user)
    if user.admin
      Update.order('created_at desc')
    else
      investment_ids = user.sub_investments.map(&:investment_id)
      Update.where(investment_id: investment_ids).order('created_at desc')
    end
  end

  def self.ransackable_associations(_auth_object = nil)
    ['investment']
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(body created_at email_sub_investor id investment_id title updated_at)
  end
end
