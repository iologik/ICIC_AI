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
class Increase < Withdraw
  belongs_to :transfer_from, class_name: 'SubInvestment', optional: true

  after_initialize :build_due_date
  after_create :notify_to_investor

  def name
    if is_transfer
      "Transferred from #{transfer_from.investment.name}" if transfer_from
    else
      "Increase #{number_to_currency(amount, precision: 2)} for #{sub_investment.investment.name}"
    end
  end

  def real_amount
    0 - amount
  end

  def should_generate_payment?
    false
  end

  private

  def build_due_date
    self.due_date = Time.zone.today unless due_date
  end

  def log_event_for_transfer
    sub_investment.log_event("Transferred from #{transfer_from.investment.name}", due_date) if is_transfer
  end

  def notify_to_investor
    return unless is_notify_to_investor

    pdf = BuildIncreaseService.new.call(self)
    filename = "#{admin_user.name}'s increase #{check_no}".tr('/', '-')
    pdf.render_file "#{filename}.pdf"
    IncreaseMailer.increase(self, filename, target_email).deliver
    File.delete("#{filename}.pdf")
  end
end
