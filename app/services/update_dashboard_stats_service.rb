# frozen_string_literal: true

class UpdateDashboardStatsService < BaseService
  def call
    DashboardFirstColumnCalculatorJob.perform_now
    DashboardSecondColumnCalculatorJob.perform_now
    DashboardThirdColumnCalculatorJob.perform_now
    DashboardFourthColumnCalculatorJob.perform_now
  end
end
