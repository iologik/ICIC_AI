# frozen_string_literal: true

# == Schema Information
#
# Table name: withdraws
#
#  id                    :integer          not null, primary key
#  amount                :decimal(12, 2)
#  check_no              :string(255)
#  due_date              :date
#  is_notify_investor    :boolean
#  is_notify_to_investor :boolean
#  is_transfer           :boolean          default(FALSE)
#  paid                  :boolean          default(FALSE)
#  paid_date             :date
#  type                  :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  admin_user_id         :integer
#  sub_investment_id     :integer
#  transfer_from_id      :integer
#  transfer_to_id        :integer
#
# Indexes
#
#  index_withdraws_on_admin_user_id      (admin_user_id)
#  index_withdraws_on_sub_investment_id  (sub_investment_id)
#  index_withdraws_on_transfer_from_id   (transfer_from_id)
#  index_withdraws_on_transfer_to_id     (transfer_to_id)
#
class Withdraw < ApplicationRecord
  include TargetEmail

  # attr_accessible :admin_user_id, :sub_investment_id, :amount,:due_date, :check_no, :status, :is_transfer, :transfer_to, :transfer_from

  belongs_to :admin_user
  belongs_to :sub_investment
  belongs_to :transfer_to, class_name: 'SubInvestment', optional: true

  has_one :payment, dependent: :destroy # not include increase

  # before_save :set_paid_date
  # after_save :adjust_sub_investment, if: :amount_changed?
  after_create :log_event_for_transfer
  after_create :increase_sub_investment_amount
  after_create :notify_to_investor
  after_destroy :decrease_sub_investment_amount
  after_destroy :adjust_sub_investment
  after_commit :adjust_sub_investment

  # TODO: it is better to make withdraw(increase) not editable, and it should affect sub_investment when withdraw is destroyed

  include ActionView::Helpers::NumberHelper

  validates :amount, numericality: { greater_than_or_equal_to: 0.01 }, presence: true
  validates :due_date, presence: true
  validate :cannot_before_effect_date, :cannot_after_end_date

  scope :increase, -> { where(type: 'Increase') }
  # TODO: name and payment_message are nearly the same
  def name
    if is_transfer
      if transfer_to
        "Transferred to #{transfer_to.try(:investment).try(:name)}"
      else
        "Transferred to #{sub_investment.transferred_to.try(:investment).try(:name)}" # just for old data
      end
    else
      "Withdraw of #{number_to_currency(amount, precision: 2)} from #{sub_investment.investment.name}"
    end
  end

  # just for payment
  def payment_message(pay_to_name)
    if is_transfer
      if transfer_to
        "Transferred to #{transfer_to.try(:investment).try(:name)}"
      else
        "Transferred to #{sub_investment.transferred_to.try(:investment).try(:name)}" # just for old data
      end
    else
      "Withdraw #{amount} from #{pay_to_name}"
    end
  end

  def real_amount
    amount
  end

  def should_generate_payment?
    true
  end

  def log_event_for_transfer
    sub_investment.log_event("Transferred to #{transfer_to.investment.name}", due_date) if is_transfer
  end

  # rubocop:disable Metrics/AbcSize
  def destroy_as_transfer
    if type == 'Increase'
      if is_transfer?
        relevant_withdraw = Withdraw.where(transfer_to_id: sub_investment_id, sub_investment_id: transfer_from_id, amount: amount).first
        relevant_withdraw.payment.destroy # destroy paid transfer payment
        relevant_withdraw.destroy
        relevant_withdraw.sub_investment.affect_investment(0 - amount)
      end
      sub_investment.affect_investment(amount)
    else
      if is_transfer?
        relevant_withdraw = Withdraw.where(type: 'Increase', transfer_from_id: sub_investment_id, sub_investment_id: transfer_to_id, amount: amount).first
        relevant_withdraw.destroy
        relevant_withdraw.sub_investment.affect_investment(amount)
      end
      sub_investment.affect_investment(0 - amount)
      payment.destroy # destroy paid transfer payment
    end
    destroy
  end
  # rubocop:enable Metrics/AbcSize

  private

  def cannot_before_effect_date
    return unless due_date && due_date < sub_investment.start_date

    errors.add(:due_date, "can not be before sub-investment start date #{sub_investment.start_date}")
  end

  def cannot_after_end_date
    return unless due_date && due_date > sub_investment.end_date

    errors.add(:due_date, "can not be after sub-investment end date #{sub_investment.end_date}")
  end

  def increase_sub_investment_amount
    return unless type == 'Increase'

    UpdateSubInvestmentPaymentWorker.perform_async(sub_investment.id)
  end

  def decrease_sub_investment_amount
    return unless type == 'Increase'

    UpdateSubInvestmentPaymentWorker.perform_async(sub_investment.id)
  end

  def set_paid_date
    return unless paid == true && (saved_change_to_paid? || !id)

    self.paid_date = DateTime.now
  end

  def notify_to_investor
    return unless is_notify_to_investor

    pdf = BuildWithdrawService.new.call(self)
    filename = "#{admin_user.name}'s withdraw #{check_no}".tr('/', '-')
    pdf.render_file "#{filename}.pdf"
    WithdrawMailer.withdraw(self, filename, target_email).deliver
    File.delete("#{filename}.pdf")
  end

  def adjust_sub_investment
    UpdateSubInvestmentAmountStatsWorker.perform_async(sub_investment_id)
  end
end
