# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  # menu false

  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  action_item :report, only: :index do
    link_to 'Payments Report', admin_payment_reports_path
  end

  content title: proc { I18n.t('active_admin.dashboard') } do
    render 'table_with_totals'
  end
end
