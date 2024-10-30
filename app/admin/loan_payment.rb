# frozen_string_literal: true

ActiveAdmin.register LoanPayment do
  menu false

  actions :all, except: [:index]
  permit_params :borrower_id,
                :memo,
                :payment_kind,
                :start_date,
                :remark,
                :loan_amount,
                :rate,
                :currency,
                :amount,
                :paid,
                :loan_id,
                :due_date,
                :cash_back_id,
                :check_no

  controller do
    skip_before_action :verify_authenticity_token, only: [:batch_action]

    # rubocop:disable Metrics/AbcSize
    def destroy
      payment = LoanPayment.find(params[:id])
      # destroy
      payment.destroy
      # affect amount
      if payment.cash_back && payment.paid
        payment.loan.affect_investment(0 - payment.amount) # equals unpaid
      end
      # regenerate payments
      payment.loan.adjust_payment if payment.cash_back

      redirect_to admin_loan_path(payment.loan_id), notice: I18n.t('active_admin.loan_payments.payment_deleted')
    end
    # rubocop:enable Metrics/AbcSize
  end

  batch_action :destroy, false # disable here, but added as the last batch action

  batch_action :mark_as_paid do |selection|
    loan_payments = LoanPayment.find(selection)
    loan_payments.each(&:paid!)
    redirect_to admin_loan_path(loan_payments.first.loan_id), notice: I18n.t('active_admin.loan_payments.payment_set')
  end

  # batch_action :mark_as_pending do |selection|
  #  Payment.find(selection).each do |payment|
  #    payment.pending!
  #  end
  #  redirect_to session[:payment_index_url], :notice => "Payment Set"
  # end

  # customize delete action
  batch_action :destroy do |selection|
    loan_payments = LoanPayment.find(selection)
    loan_payments.each(&:destroy)
    redirect_to admin_loan_path(loan_payments.first.loan_id), notice: I18n.t('active_admin.loan_payments.payment_deleted')
  end

  show do
    attributes_table do
      row :borrower
      row :amount do |a|
        number_to_currency(a.amount, precision: 2)
      end
      row :due_date
      row :loan
      row :check_no
      row :paid
      row :memo
    end
  end
  ## add this form is because is
  ## we do not use the default date format
  form do |f|
    f.inputs do
      f.input :borrower, input_html: { disabled: true }
      f.input :loan, input_html: { disabled: true }
      f.input :due_date, order: %i(year month day), use_two_digit_numbers: true
      f.input :amount
      f.input :memo
      f.input :payment_kind, label: 'Payment Type'
      f.input :check_no
      f.input :paid
    end

    f.actions do
      f.action :submit, label: 'Save'
      f.action :cancel, label: 'Cancel', class: 'cancel'
    end
  end

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
