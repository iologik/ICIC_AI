# frozen_string_literal: true

ActiveAdmin.register LoanDraw do
  menu false
  permit_params :loan, :loan_id, :due_date, :amount, :check_no

  # actions :all, :except => [:index]

  controller do
    def new
      @loan_draw = LoanDraw.new
      return unless params[:loan_id]

      loan = Loan.find(params[:loan_id])
      @loan_draw.loan = loan
    end

    def destroy
      loan_draw = LoanDraw.find(params[:id])
      loan_draw.destroy
      redirect_to admin_loan_path(loan_draw.loan_id)
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
