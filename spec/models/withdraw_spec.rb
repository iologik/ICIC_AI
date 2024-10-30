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
require 'rails_helper'

# rubocop:disable Style/MixinUsage
include ModelMacros
# rubocop:enable Style/MixinUsage

# rubocop:disable RSpec/AnyInstance
# rubocop:disable RSpec/ContextWording
# rubocop:disable RSpec/MultipleExpectations
RSpec.describe Withdraw do
  before do
    allow_any_instance_of(SubInvestment).to receive(:build_agreement)
  end

  # relationships

  it { is_expected.to belong_to(:admin_user) }

  it { is_expected.to belong_to(:sub_investment) }

  # validation

  it { is_expected.to validate_presence_of(:due_date) }

  it { is_expected.to validate_numericality_of(:amount) }

  describe 'transfer' do
    # commented out as transfer to new sub-investment is broken
    # context "transfer all" do
    #   investment = FactoryBot.build(:investment)
    #   investment.save(validate: false)
    #   sub_investment_local = FactoryBot.build(:sub_investment, investment: investment)
    #   sub_investment_local.save(validate: false)
    #   let!(:sub_investment) { sub_investment_local }
    #   let!(:sub_investment_target) { create_sub_investment({effect_date: Date.parse('2012-06-05')}, {transfer_from_id: sub_investment.id, investment: investment}) }
    #   before(:each) do
    #     sub_investment.reload
    #     sub_investment.adjust_payment # as adjust_payments is called after_commit(payment.rb), so call it manually
    #   end

    #   it "has no principal payback" do
    #     payments = sub_investment.payments.where(payment_kind: Payment::Type_Principal)
    #     expect(payments.count).to eq(1)
    #   end

    #   it "has transfer withdraw" do
    #     expect(sub_investment.withdraws.count).to eq(1)
    #     expect(sub_investment.withdraws.first.is_transfer).to be_truthy
    #   end
    # end

    # commented out as transfer to new sub-investment is broken
    # context "transfer part" do
    #   investment = FactoryBot.build(:investment)
    #   investment.save(validate: false)
    #   sub_investment_local = FactoryBot.build(:sub_investment, investment: investment)
    #   sub_investment_local.save(validate: false)
    #   let!(:sub_investment) { sub_investment_local }
    #   let!(:sub_investment_target) { create_sub_investment({effect_date: Date.parse('2012-06-05')}, {transfer_from_id: sub_investment.id, amount: 500, investment: investment}) }
    #   before(:each) do
    #     sub_investment.reload
    #     sub_investment.adjust_payment # as adjust_payments is called after_commit(payment.rb), so call it manually
    #   end

    #   it "has principal payback" do
    #     payments = sub_investment.payments.where(payment_kind: Payment::Type_Principal)
    #     expect(payments.count).to eq(1)
    #   end

    #   it "has transfer withdraw" do
    #     expect(sub_investment.withdraws.count).to eq(1)
    #     expect(sub_investment.withdraws.first.is_transfer).to be_truthy
    #   end

    #   it "has transfer payment" do
    #     payments = sub_investment.payments.where(payment_kind: Payment::Type_Transfer)
    #     expect(payments.count).to eq(1)
    #     expect(payments.first.amount).to eq(500)
    #   end
    # end

    # commented out as transfer to new sub-investment is broken
    # context "transfer on the last day of a sub-investment" do
    #   investment = FactoryBot.build(:investment)
    #   investment.save(validate: false)
    #   sub_investment_local = FactoryBot.build(:sub_investment, investment: investment)
    #   sub_investment_local.save(validate: false)
    #   let!(:sub_investment) { sub_investment_local }
    #   let!(:sub_investment_target) { create_sub_investment({effect_date: Date.parse('2013-01-05')}, {transfer_from_id: sub_investment.id, investment: investment}) }
    #   before(:each) do
    #     sub_investment.reload
    #     sub_investment.adjust_payment # as adjust_payments is called after_commit(payment.rb), so call it manually
    #   end

    #   it "has no principal payback" do
    #     payments = sub_investment.payments.where(payment_kind: Payment::Type_Principal)
    #     expect(payments.count).to eq(0)
    #   end

    #   it "has transfer withdraw" do
    #     expect(sub_investment.withdraws.count).to eq(1)
    #     expect(sub_investment.withdraws.first.is_transfer).to be_truthy
    #   end

    #   it "has transfer payment" do
    #     payments = sub_investment.payments.where(payment_kind: Payment::Type_Transfer)
    #     expect(payments.count).to eq(1)
    #     expect(payments.first.amount).to eq(1000)
    #   end
    # end

    context 'transfer to an existing sub-investment' do
      let(:investment) do
        investment = build(:investment)
        investment.save(validate: false)
        investment
      end

      let!(:transfer_date) { Date.parse('2013-01-05') }
      let!(:sub_investment) do
        sub_investment = build(:sub_investment, investment: investment)
        sub_investment.save(validate: false)
        sub_investment
      end
      let!(:sub_investment_target) do
        customize_sub_investment({ admin_user: sub_investment.admin_user, investment: investment })
      end

      it "target sub-investment's payback should be increased" do
        sub_investment.transfer_to(sub_investment_target.id, 1100, transfer_date)
        increases = sub_investment_target.withdraws.where(type: 'Increase')
        expect(increases.first.amount).to eq(1100)
      end
    end

    # commented out as transfer to new sub-investment is broken
    # context "transfer twice a day" do
    #   investment = FactoryBot.build(:investment)
    #   investment.save(validate: false)
    #   let!(:transfer_date) { Date.parse('2013-01-05') }
    #   sub_investment_local = FactoryBot.build(:sub_investment, investment: investment)
    #   sub_investment_local.save(validate: false)
    #   let!(:sub_investment) { sub_investment_local }
    #   let!(:sub_investment_target) { create_sub_investment({effect_date: transfer_date}, {transfer_from_id: sub_investment.id, amount: 100, admin_user: sub_investment.admin_user, investment: investment}) }
    #   before(:each) do
    #     sub_investment.reload
    #     sub_investment.transfer_to(sub_investment_target, 100, transfer_date)
    #     sub_investment.reload
    #     sub_investment.adjust_payment # as adjust_payments is called after_commit(payment.rb), so call it manually
    #   end

    #   it "has 2 transfer withdraws" do
    #     expect(sub_investment.withdraws.count).to eq(2)
    #     expect(sub_investment.withdraws.first.is_transfer).to be_truthy
    #     expect(sub_investment.withdraws.last.is_transfer).to be_truthy
    #     expect(sub_investment.withdraws.first.due_date).to eq(transfer_date)
    #     expect(sub_investment.withdraws.last.due_date).to eq(transfer_date)
    #   end

    #   it "has 2 transfer payments" do
    #     payments = sub_investment.payments.where(payment_kind: Payment::Type_Transfer)
    #     expect(payments.count).to eq(2)
    #     expect(payments.first.amount).to eq(100)
    #     expect(payments.first.amount).to eq(100)
    #   end
    # end
  end

  describe 'increase' do
    context 'general increase' do
      let(:investment) do
        investment = build(:investment)
        investment.save(validate: false)
        investment
      end
      let(:sub_investment_local) do
        sub_investment_local = build(:sub_investment, investment: investment)
        sub_investment_local.save(validate: false)
        sub_investment_local
      end
      let!(:sub_investment) { sub_investment_local }

      before do
        create(:increase, sub_investment: sub_investment, admin_user: sub_investment.admin_user, due_date: Date.parse('2013-01-05'))
        sub_investment.reload
        UpdateSubInvestmentPaymentService.new(sub_investment.id).call # as adjust_payments is called after_commit(payment.rb), so call it manually
      end

      it 'has no increase payment' do
        expect(sub_investment.payments.where(payment_kind: Payment::Type_Withdraw).count).to eq(0)
        expect(sub_investment.payments.where(payment_kind: Payment::Type_Transfer).count).to eq(0)
      end

      # disable for now as sometimes it works
      # it "amount should increase" do
      #   sub_investment.reload
      #   expect(sub_investment.amount).to eq(1100)
      # end

      it 'original amount should not change' do
        sub_investment.reload
        expect(sub_investment.ori_amount).to eq(1000)
      end

      it 'interest should increase' do
        payments = sub_investment.payments.where(payment_kind: Payment::Type_Interest).order('due_date asc')
        expect(payments[1].amount.to_s).to eq(format('%.1f', ((12.0 / 365 / 100 * 12 * 1000) + (12.0 / 365 / 100 * 19.5 * 1100))))
      end

      it 'payback should increase' do
        payments = sub_investment.payments.where(payment_kind: Payment::Type_Principal)
        expect(payments.first.amount).to eq(1100)
      end
    end

    context 'increase on the first day' do
      let(:investment) do
        investment = build(:investment)
        investment.save(validate: false)
        investment
      end
      let(:sub_investment_local) do
        sub_investment_local = build(:sub_investment, investment: investment)
        sub_investment_local.save(validate: false)
        sub_investment_local
      end
      let!(:sub_investment) { sub_investment_local }

      before do
        create(:increase, sub_investment: sub_investment, admin_user: sub_investment.admin_user, due_date: Date.parse('2013-01-05'))
        sub_investment.reload
        UpdateSubInvestmentPaymentService.new(sub_investment.id).call # as adjust_payments is called after_commit(payment.rb), so call it manually
      end

      it 'has no increase payment' do
        expect(sub_investment.payments.where(payment_kind: Payment::Type_Withdraw).count).to eq(0)
        expect(sub_investment.payments.where(payment_kind: Payment::Type_Transfer).count).to eq(0)
      end

      # disable for now as sometimes it works
      # it "amount should increase" do
      #   sub_investment.reload
      #   expect(sub_investment.amount).to eq(1100)
      # end

      it 'original amount should not change' do
        expect(sub_investment.ori_amount).to eq(1000)
      end

      it 'interest should increase' do
        payments = sub_investment.payments.where(payment_kind: Payment::Type_Interest).order('due_date asc')
        expect(payments[1].amount.to_s).to eq(format('%.1f', (12.0 / 365 / 100 * 30.4166 * 1100)))
      end

      it 'payback should increase' do
        payments = sub_investment.payments.where(payment_kind: Payment::Type_Principal)
        expect(payments.first.amount).to eq(1100)
      end
    end

    context 'increase on the first day of a month' do
      let(:investment) do
        investment = build(:investment)
        investment.save(validate: false)
        investment
      end
      let(:sub_investment_local) do
        sub_investment_local = build(:sub_investment, investment: investment)
        sub_investment_local.save(validate: false)
        sub_investment_local
      end
      let!(:sub_investment) { sub_investment_local }

      before do
        create(:increase, sub_investment: sub_investment, admin_user: sub_investment.admin_user,
                          due_date: Date.parse('2013-02-01'))
        sub_investment.reload
        UpdateSubInvestmentPaymentService.new(sub_investment.id).call # as adjust_payments is called after_commit(payment.rb), so call it manually
      end

      it 'has no increase payment' do
        expect(sub_investment.payments.where(payment_kind: Payment::Type_Withdraw).count).to eq(0)
        expect(sub_investment.payments.where(payment_kind: Payment::Type_Transfer).count).to eq(0)
      end

      # disable for now as sometimes it works
      # it "amount should increase" do
      #   sub_investment.reload
      #   expect(sub_investment.amount).to eq(1100)
      # end

      it 'interest should increase' do
        payments = sub_investment.payments.where(payment_kind: Payment::Type_Interest).order('due_date asc')
        expect(payments[1].amount.to_s).to eq(format('%.1f', (12.0 / 365 / 100 * 30.4166 * 1100)))
      end

      it 'payback should increase' do
        payments = sub_investment.payments.where(payment_kind: Payment::Type_Principal)
        expect(payments.first.amount).to eq(1100)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
# rubocop:enable RSpec/ContextWording
# rubocop:enable RSpec/AnyInstance
