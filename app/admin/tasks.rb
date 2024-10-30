# frozen_string_literal: true

ActiveAdmin.register Task do
  menu parent: 'Reference Tables'

  permit_params :date, :description, :status, :sub_investment_id

  filter :status, as: :select, collection: Task::ALL_STATUS
  filter :date
  filter :sub_investment

  controller do
    def new
      @task = Task.new
      return if params[:sub_investment].blank?

      @task.sub_investment_id = params[:sub_investment]
    end
  end

  form do |f|
    f.inputs do
      f.input :sub_investment
      f.input :date, order: %i(year month day), use_two_digit_numbers: true
      f.input :status, as: :select, collection: Task::ALL_STATUS, include_blank: false
      f.input :description, input_html: { rows: 5 }
    end

    f.actions
  end

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
