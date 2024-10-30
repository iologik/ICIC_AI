# frozen_string_literal: true

module TargetEmail
  extend ActiveSupport::Concern

  private

  def target_email
    emails = if Rails.env.production?
               "#{ENV.fetch('admin_emails', nil)},#{admin_user.email}"
             else
               ENV.fetch('admin_emails', nil)
             end

    emails.split(',')
  end
end
