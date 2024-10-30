# frozen_string_literal: true

# ActiveAdmin.register AccruedNotification do
ActiveAdmin.register_page 'Accrued Notification' do
  menu parent: 'Reports'

  controller do
    def index
      sub_investments = InterestPeriod.where.not(accrued_per_annum: 0).map(&:sub_investment)
      sub_investments.delete(nil)
      @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Time.zone.today
      @sub_investments = sub_investments.sort_by(&:name).reject { |x| x.investment.imor? }.uniq
    end
  end

  content title: 'Accrued Notification' do
    render 'index'
  end
end
