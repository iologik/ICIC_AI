# frozen_string_literal: true

# ActiveAdmin.register RetainedNotification do
ActiveAdmin.register_page 'Interest Reserve Notification' do
  menu parent: 'Reports'

  controller do
    def index
      @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Time.zone.today
      @sub_investments = InterestPeriod.where.not(retained_per_annum: 0).map(&:sub_investment).sort_by(&:name).uniq
    end
  end

  content title: 'Interest Reserve Notification' do
    render 'index'
  end
end
