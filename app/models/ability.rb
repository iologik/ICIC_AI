# frozen_string_literal: true

# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin
      can :manage, :all
    else
      cannot :list, AdminUser
      can :read, AdminUser, id: AdminUser.where(id: user.id).pluck(:id)
      can :read, UserPayment
      # TODO: http://localhost:3000/admin/sub_investors should not be able to visit this page, now we get error when visit this page
      # cannot :create, SubInvestment todo new page can always be visited, although can not create
      can :read, SubInvestment, id: SubInvestment.where(admin_user_id: user.id).pluck(:id)
      can :read, Post
      cannot :upload_signed_agreement, SubInvestment
      cannot :remote_agreement, SubInvestment
      can :download_signed_risk_acknowledgment, AdminUser
      # TODO: sub_investment index page error
    end
  end
end
