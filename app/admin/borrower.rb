# frozen_string_literal: true

ActiveAdmin.register Borrower do
  permit_params :first_name, :last_name, :email, :company
  menu parent: 'Loan Tables'

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :company
    actions
  end

  filter :first_name
  filter :last_name
  filter :email
  filter :company

  form do |f|
    f.inputs do
      f.input :last_name
      f.input :first_name
      f.input :email
      f.input :company
    end
    f.actions
  end

  show do |_user|
    columns do
      column do
        panel 'Borrower Details' do
          attributes_table_for borrower do
            row :name
            row :email
            row :company
            row :created_at
            row :updated_at
          end
        end
      end
    end
  end

  sidebar('title', only: %i(new edit create update change_password save_password), id: 'blank_space_panel') {}
end
