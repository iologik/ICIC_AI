# frozen_string_literal: true

ActiveAdmin.register Event do
  menu false
  permit_params :date, :description, :sub_investment_id

  controller do
    def destroy
      event = Event.find(params[:id])
      # destroy
      event.destroy
      redirect_to admin_sub_investment_path(event.sub_investment_id), notice: I18n.t('active_admin.events.deleted')
    end
  end
end
