# frozen_string_literal: true

ActiveAdmin.register Withdraw do
  menu false
  permit_params :admin_user_id,
                :sub_investment_id,
                :amount, :due_date,
                :check_no,
                :status,
                :is_transfer,
                :transfer_to,
                :transfer_from,
                :paid,
                :paid_date,
                :is_notify_to_investor

  controller do
    def new
      @withdraw = Withdraw.new
      if params[:sub_investment_id]
        invest = SubInvestment.find(params[:sub_investment_id])
        @withdraw.sub_investment = invest
        @withdraw.admin_user = invest.admin_user
      end
      @withdraw.paid_date = Date.current
    end

    def update(options = {}, &block)
      super
      @withdraw = Withdraw.find(params[:id])
      UpdatePaymentFromWithdrawService.new.call(@withdraw)
    end

    def create
      super
      UpdatePaymentFromWithdrawService.new.call(@withdraw)
      UpdateSubInvestmentStatsWorker.perform_async(@withdraw.sub_investment_id)
    end

    # also delete relevant withdraw
    # affect sub-investment amount
    def destroy
      withdraw = Withdraw.find(params[:id])
      withdraw.destroy_as_transfer
      redirect_to admin_sub_investment_path(withdraw.sub_investment_id)
    end
  end

  form do |f|
    f.inputs do
      f.input :admin_user, label: 'Investor', include_blank: false, input_html: { disabled: true }
      f.input :admin_user_id, label: 'Investor', include_blank: false, as: 'hidden'
      f.input :sub_investment, include_blank: false, input_html: { disabled: true }
      f.input :sub_investment_id, include_blank: false, as: 'hidden'
      f.input :amount
      f.input :due_date, order: %i(year month day), use_two_digit_numbers: true
      f.input :paid_date, order: %i(year month day), use_two_digit_numbers: true
      f.input :check_no
      f.input :paid
      f.input :is_notify_to_investor, label: 'Notify To Investor'
    end

    f.actions
  end

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
