# frozen_string_literal: true

ActiveAdmin.register Loan do
  menu parent: 'Loan Tables'
  form partial: 'form'
  permit_params :borrower_id,
                :scheduled,
                :months,
                :amount,
                :ori_amount,
                :currency,
                :name,
                :description,
                loan_interest_periods_attributes: %i(effect_date per_annum)

  controller do
    skip_before_action :verify_authenticity_token, only: [:update]
  end

  filter :borrower

  before_create do |loan|
    loan.loan_interest_periods = loan
                                 .loan_interest_periods
                                 .select(&:valid?)
  end

  index do
    column :id
    column :name do |item|
      link_to item.name, "/admin/loans/#{item.id}"
    end
    column :amount do |item|
      number_to_currency(item.amount, precision: 2)
    end
    column :currency
    column :scheduled
    column :months
    # column :status
    column :start_date
    # actions
  end

  #   form do |f|
  #     f.inputs "Details" do
  #       f.input :name
  #       f.input :borrower, :include_blank => false, :as => :select, :collection => Borrower.order_by_name
  #     end
  #     f.inputs "Investment terms" do
  #       f.input :scheduled, :as => :radio, :collection => ["Monthly" , "Quarterly", "Annually"]
  #     end
  #     f.inputs "Loan" do
  #     if f.object.new_record?
  #       f.input :amount, label: 'Amount'
  #     else
  #       f.input :amount
  #     end
  #     f.input :currency , :as => :radio , :collection  => ["USD", "CAD"]
  #     f.input :months , :collection => 1..48
  #     f.has_many :loan_interest_periods do |h|
  #       h.inputs do
  #         h.input :effect_date, order: [:year, :month, :day], :use_two_digit_numbers => true
  #         h.input :per_annum
  #       # link_to_remove_association "remove task", f
  #       end
  #     end
  #   end
  #   f.actions
  # end

  show do
    columns do
      # rubocop:disable Rails/OutputSafety
      column do
        attributes_table do
          # row :id
          row 'Name' do |item|
            link_to item.name, admin_borrower_path(id: item.borrower.id)
          end
          row 'current amount' do |item|
            "#{number_to_currency(item.amount,
                                  precision: 2)} #{item.currency}  #{link_to 'Cash Back',
                                                                             new_admin_cash_back_path(loan_id: loan.id)} / #{link_to 'Draw',
                                                                                                                                     new_admin_loan_draw_path(loan_id: loan.id)}".html_safe
          end
          row :months
          row :scheduled
          row :currency
        end

        panel('Interest Periods') do
          table_for(loan.loan_interest_periods) do
            column :effect_date
            column 'Interest P.A.' do |item|
              number_to_percentage item.per_annum, precision: 2
            end
          end
        end
      end

      column do
        panel('Description') do
          "#{loan.description} <br> <div class='hide'>#{loan.description}</div> #{link_to 'Edit Description', '#',
                                                                                          class: 'edit-sub-investment-description', data: { form_url: admin_loan_path(id: loan.id), field: 'description', model: 'loan' }}".html_safe
        end
      end
      # rubocop:enable Rails/OutputSafety
    end

    form action: '/admin/loan_payments/batch_action', class: 'batch-action-form', method: 'post' do
      input name: 'batch_action', id: 'batch_action', type: 'hidden'

      # batch actions for future payments
      div class: 'dropdown_menu', id: 'batch_actions_selector' do
        a(class: 'dropdown_menu_button disabled', href: '#', style: 'margin-bottom: 10px;') { 'Batch Actions' }
        div class: 'dropdown_menu_list_wrapper', style: 'left: 22.5px; top: 181px; display: none;' do
          div class: 'dropdown_menu_nipple', style: 'left: 54.5px;'
          ul class: 'dropdown_menu_list' do
            li do
              a('class' => 'batch_action', 'href' => 'javascript:void(0)', 'data-action' => 'mark_as_paid') do
                'Mark As Paid Selected'
              end
            end
            li do
              a('class' => 'batch_action', 'href' => 'javascript:void(0)', 'data-action' => 'destroy',
                'data-confirm-message' => "Are you sure you want to delete these sub investment payments? You won't be able to undo this.") do
                'Delete Selected'
              end
            end
          end
        end
      end

      panel('Future Payments') do
        table_for(loan.loan_payments.order('DUE_DATE ASC')) do
          column '<input type="checkbox" class="collection_selection">'.html_safe do |p|
            input 'type' => 'checkbox', 'value' => p.id, 'class' => 'collection_selection',
                  'name' => 'collection_selection[]'
          end

          column :id
          column :due_date
          column 'name' do |p|
            link_to p.borrower.name, admin_borrower_path(p.borrower)
          end
          column 'amount' do |item|
            div title: item.remark do
              number_to_currency item.amount
            end
          end
          column 'check_no'
          column 'Payment Type', &:payment_kind
          column 'memo'
          column('status') { |payment| status_tag(payment.status) }
          column do |p|
            div style: 'display:inline' do
              link_to 'View', admin_loan_payment_path(p)
            end
            div style: 'display:inline' do
              link_to 'Edit', edit_admin_loan_payment_path(p)
            end
            div style: 'display:inline' do
              link_to 'Delete', admin_loan_payment_path(p.id), data: { method: 'delete', confirm: 'Are you sure?' }
            end
          end
        end
      end
    end

    if loan.loan_draws.count.positive?
      panel('Draws') do
        table_for(loan.loan_draws) do
          column 'id'
          column 'due_date' do |item|
            url = if item.instance_of?(CashBack)
                    "/admin/cash_backs/#{item.id}"
                  else
                    "/admin/loan_draws/#{item.id}"
                  end
            link_to item.due_date.strftime('%Y-%m-%d'), url
          end
          column :name
          column 'amount' do |item|
            number_to_currency item.amount
          end
          column 'check_no'
        end
      end
    end

    panel 'Amount changes', id: 'amount_change_panel' do
      steps = loan.current_amount_steps

      total_in = total_out = balance = 0

      steps.each do |step|
        total_in += (step.in || 0)
        total_out += (step.out || 0)
        balance = step.balance
      end

      div :id => 'amount_change_in', :class => 'hide', 'data-value' => number_to_currency(total_in)
      div :id => 'amount_change_out', :class => 'hide', 'data-value' => number_to_currency(total_out)
      div :id => 'amount_change_balance', :class => 'hide', 'data-value' => number_to_currency(balance)

      table_for(steps) do
        column 'date'
        column 'event', &:action
        column 'in' do |item|
          number_to_currency item.in
        end
        column 'out' do |item|
          number_to_currency item.out
        end
        column 'balance' do |item|
          number_to_currency item.balance
        end
      end
    end
  end

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
