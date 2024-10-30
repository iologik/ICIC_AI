# frozen_string_literal: true

ActiveAdmin.register Draw do
  menu false

  permit_params :investment_id, :amount, :date, :description

  actions :all, except: [:destroy]

  controller do
    def new
      @draw = Draw.new
      @draw.date = Time.zone.today
      return if params[:investment].blank?

      @draw.investment_id = params[:investment]
    end

    def current_user
      current_admin_user
    end
  end

  action_item :delete, only: :show do
    if can? :destroy,
            Draw
      link_to 'Delete Draw', "/admin/draws/#{draw.id}/destroy_self", method: :delete,
                                                                     data: { confirm: 'Are you sure?' }
    end
  end

  member_action :destroy_self, method: :delete do
    draw = Draw.find(params[:id])
    if current_admin_user.admin? && draw
      draw.destroy
      redirect_to admin_investment_path(draw.investment.id)
    end
  end

  form do |f|
    f.inputs do
      f.input :investment, include_blank: true
      if draw.new_record?
        f.input :amount, label: 'Capital Invested'
      else
        f.input :amount, label: 'Capital Invested', input_html: { disabled: 'disabled', class: 'label-input' }
      end
      f.input :date, order: %i(year month day), use_two_digit_numbers: true
      f.input :description, input_html: { style: 'height: 100px;' }
    end

    f.actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :id
          row :investment
          row 'Capital Invested' do |item|
            number_to_currency item.amount, precision: 2
          end
          row :date
          row :description
        end
      end
    end
  end

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
