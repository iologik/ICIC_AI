# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :authenticate_admin_user!, only: :login_as

  def welcome
    if current_admin_user.nil? || current_admin_user.admin
      redirect_to admin_root_path # login page
    else
      redirect_to admin_sub_investor_path(id: current_admin_user.id)
    end
  end

  def access_denied(_exception)
    redirect_to admin_sub_investor_path(id: current_admin_user.id) # , :alert => exception.message
  end

  def login_as
    sign_in(AdminUser.find(params[:id])) if current_admin_user.relevant_users.include?(params[:id].to_i)
    redirect_to request.referer
  end

  def mail_test
    # @sub_investment = SubInvestment.find(270)
    render 'mail_test', layout: false
  end
end
