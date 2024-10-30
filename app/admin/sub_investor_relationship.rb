# frozen_string_literal: true

ActiveAdmin.register SubInvestorRelationship do
  menu parent: 'Reference Tables'
  permit_params :admin_user_id, :account_id

  index do
    selectable_column

    column 'Sub Investor' do |item|
      link_to item.admin_user&.name, admin_sub_investor_path(id: item.admin_user&.id)
    end

    column 'Sub Investor' do |item|
      link_to item.account&.name, admin_sub_investor_path(id: item.account.id)
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row 'Sub Investor' do
        sub_investor_relationship.admin_user
      end
      row 'Sub Investor' do |_a|
        sub_investor_relationship.account
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :admin_user, label: 'Sub Investor', as: :select, collection: AdminUser.order_by_name
      f.input :account,    label: 'Sub Investor', as: :select, collection: AdminUser.order_by_name
    end

    f.actions
  end
end
