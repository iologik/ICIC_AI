# frozen_string_literal: true

ActiveAdmin.register Fee do
  permit_params :id,
                :sub_investment,
                :description,
                :amount,
                :collected

  scope :collected
  scope :uncollected

  filter :sub_investment, as: :select, collection: SubInvestment.order_name

  index do
    total_amount = 0
    fees.each do |fee|
      total_amount += fee.amount
    end

    div class: 'hide total_fee_amount' do
      number_to_currency total_amount
    end

    selectable_column

    column 'Sub Investment' do |item|
      item.sub_investment.name
    end

    column 'description', &:description

    column :amount do |item|
      number_to_currency(item.amount, precision: 2)
    end

    column :currency do |item|
      item.sub_investment.currency
    end

    column :collected
    # actions

    column do |p|
      div style: 'display:inline' do
        link_to 'View', admin_fee_path(p)
      end
      div style: 'display:inline' do
        link_to 'Edit', edit_admin_fee_path(p)
      end
      div style: 'display:inline' do
        link_to 'Delete', admin_fee_path(p.id), data: { method: 'delete', confirm: 'Are you sure?' } unless p.withdraw
      end
    end
  end

  controller do
    def destroy
      fee = Fee.find(params[:id])
      withdraw = fee.withdraw

      fee.destroy
      withdraw.destroy

      redirect_to admin_fees_path, notice: I18n.t('active_admin.fees.delete')
    end
  end
end
