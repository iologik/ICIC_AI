# frozen_string_literal: true

class ContactAdminService
  def call(email, name, message)
    AdminMailer.contact_mail(email, name, message).deliver
  end
end
