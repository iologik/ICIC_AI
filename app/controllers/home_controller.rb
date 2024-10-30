# frozen_string_literal: true

class HomeController < ApplicationController
  def index; end

  def about
    @about_page = true
  end

  def contact
    @message = flash[:message] if flash[:message]
  end

  def handle_contact
    success = verify_recaptcha(action: 'contact', minimum_score: 0.7, secret_key: ENV.fetch('RECAPTCHA_SECRET_KEY_V3', nil))
    if success
      ContactAdminService.new.call(params[:email], params[:username], params[:message])
      flash[:message] = I18n.t('contact_welcome')
      flash.keep(:message)
    end
    redirect_to :contact
  end
end
