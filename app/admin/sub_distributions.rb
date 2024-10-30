# frozen_string_literal: true

ActiveAdmin.register SubDistribution do
  menu false

  actions :all # , :except => [:new, :create, :edit, :update, :destroy]
  permit_params :sub_investment,
                :transfer_to,
                :sub_investment_id,
                :transfer_to_id,
                :amount,
                :date,
                :sub_distribution_type,
                :admin_user_id

  config.sort_order = nil

  config.clear_action_items!

  filter :date
  filter :admin_user
  # TODO: why proc instead of lambda?
  filter :admin_user, label: 'Sub Investor', as: :select, collection: proc {
    Investment.find(params[:investment] || session['investment_for_sub_distributions']).sub_investments.map(&:admin_user)
  }

  scope :by_investment, default: true

  action_item :new, only: :index do
    link_to 'New Sub Distribution',
            new_admin_sub_distribution_path(investment_id: Thread.current['investment_for_sub_distributions'])
  end

  controller do
    skip_before_action :verify_authenticity_token, only: :return_of_capital
    before_action :set_investment, only: %i(index new create)
    before_action :save_url, only: :index
    before_action :set_transfer_to_sub_investments, only: %i(new create)

    def new
      @sub_distribution = SubDistribution.new
      @sub_distribution.sub_distribution_type = 'Payment'
    end

    private

    def set_investment
      # place in session because clear filter will clear any parameter
      # place in thread because model can access thread share variable
      session['investment_for_sub_distributions'] = params[:investment] if params[:investment]
      Thread.current['investment_for_sub_distributions'] = session['investment_for_sub_distributions']
    end

    def save_url
      session[:sub_distribution_index_url] = request.original_url
    end

    def sub_distributions_url
      request.env['HTTP_REFERER'].gsub('new', '')
    end

    # rubocop:disable Metrics/AbcSize
    def set_transfer_to_sub_investments
      sub_investments = Investment.find(Thread.current['investment_for_sub_distributions']).sub_investments

      transfer_to_collection = []
      sub_investments.each do |sub_investment|
        user = sub_investment.admin_user
        temp_sub_investments = user.sub_investments.reject { |x| x.id == sub_investment.id }
        transfer_to_collection += temp_sub_investments.map do |sub_invest|
          ["#{sub_invest.name} #{CommonHelper.number_to_currency(sub_invest.amount, precision: 2)}",
           "#{sub_invest.id}-#{sub_investment.id}"]
        end
      end
      Thread.current['transfer_to_collection'] = transfer_to_collection
    end
    # rubocop:enable Metrics/AbcSize
  end

  index do
    amount_total = 0
    sub_distributions.each do |sub_dis|
      amount_total += sub_dis.amount
    end
    div id: 'sub_distribution_amount_total', class: 'hide' do
      number_to_currency(amount_total)
    end

    selectable_column

    column :id do |d|
      div 'data-year' => d.date.year, 'data-month' => d.date.month, 'data-day' => d.date.day do
        d.id
      end
    end
    column :sub_investment
    column :sub_distribution_type
    column :transfer_to
    column :amount do |d|
      number_to_currency(d.amount)
    end
    column :date
    # Return of capital to investor

    # actions
  end

  form do |f|
    f.inputs do
      f.input :current_admin_user_id, input_html: { disabled: 'disabled', value: current_admin_user.id }
      f.input :sub_investment_id, as: :select, collection: Investment.find(Thread.current['investment_for_sub_distributions']).sub_investments.map { |sub_invest|
                                                             ["#{sub_invest.name} #{number_to_currency(sub_invest.amount, precision: 2)}", sub_invest.id]
                                                           }
      f.input :sub_distribution_type, as: :radio, collection: %w(Payment Transfer)
      f.input :transfer_to_id, as: :select, collection: Thread.current['transfer_to_collection']
      f.input :amount
      f.input :date, order: %i(year month day), use_two_digit_numbers: true
    end

    f.actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :id
          row :sub_investment
          row :sub_distribution_type
          row :transfer_to
          row :amount do |item|
            number_to_currency item.amount, precision: 2
          end
          row :date
        end
      end
    end
  end

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
