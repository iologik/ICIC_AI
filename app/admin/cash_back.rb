# frozen_string_literal: true

ActiveAdmin.register CashBack do
  permit_params :loan_id, :amount, :due_date, :check_no, :type

  menu false

  # actions :all, :except => [:index]

  controller do
    def new
      @cash_back = CashBack.new
      return unless params[:loan_id]

      loan = Loan.find(params[:loan_id])
      @cash_back.loan = loan
    end

    def destroy
      cash_back = CashBack.find(params[:id])
      cash_back.destroy
      redirect_to admin_loan_path(cash_back.loan_id)
    end
  end

  form do |f|
    f.inputs do
      f.input :loan, include_blank: false, input_html: { disabled: true }
      f.input :loan_id, as: 'hidden'
      f.input :amount
      f.input :due_date, order: %i(year month day), use_two_digit_numbers: true
      f.input :check_no
    end

    f.actions
  end

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
