# frozen_string_literal: true

# == Schema Information
#
# Table name: sub_investments
#
#  id                        :integer          not null, primary key
#  amount                    :decimal(12, 2)
#  archive_date              :date
#  creation_date             :date
#  currency                  :string(255)
#  current_accrued_amount    :decimal(, )
#  current_retained_amount   :decimal(, )
#  description               :text
#  exchange_rate             :decimal(, )
#  initial_description       :text
#  is_notify_investor        :boolean
#  memo                      :string(120)
#  months                    :integer
#  name                      :string           default("")
#  ori_amount                :decimal(12, 2)
#  private_note              :text
#  referrand_amount          :float
#  referrand_one_time_amount :decimal(12, 2)
#  referrand_one_time_date   :date
#  referrand_percent         :float
#  referrand_scheduled       :string(255)
#  remote_agreement_url      :string
#  scheduled                 :string(255)
#  signed_agreement_url      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  account_id                :integer
#  admin_user_id             :integer
#  envelope_id               :string
#  investment_id             :integer
#  investment_status_id      :integer
#  referrand_user_id         :integer
#  sub_investment_kind_id    :string
#  sub_investment_source_id  :string
#  transfer_from_id          :integer
#
# Indexes
#
#  index_sub_investments_on_account_id            (account_id)
#  index_sub_investments_on_admin_user_id         (admin_user_id)
#  index_sub_investments_on_investment_id         (investment_id)
#  index_sub_investments_on_investment_status_id  (investment_status_id)
#  index_sub_investments_on_transfer_from_id      (transfer_from_id)
#
require 'rails_helper'

# rubocop:disable Style/MixinUsage
include ModelMacros
# rubocop:enable Style/MixinUsage

# rubocop:disable RSpec/AnyInstance
# rubocop:disable RSpec/ContextWording
# rubocop:disable RSpec/MultipleExpectations
# rubocop:disable RSpec/NoExpectationExample
# rubocop:disable RSpec/NestedGroups
RSpec.describe SubInvestment do
  before do
    allow_any_instance_of(described_class).to receive(:build_agreement)
  end

  # relationships

  it { is_expected.to belong_to(:admin_user) }

  it { is_expected.to belong_to(:investment) }

  it { is_expected.to belong_to(:investment_status) }

  it { is_expected.to have_many(:payments) }

  it { is_expected.to have_many(:withdraws) }

  # validation

  # it { should validate_numericality_of(:months) }

  # it { should validate_numericality_of(:amount) }

  describe 'name' do
    context 'with admin_user' do
      subject { general_sub_investment.name }

      it { is_expected.to eq("last name first name-investment name-USD #{Time.zone.today}") }
    end

    context 'without admin_user' do
      subject { customize_sub_investment(admin_user: nil).name }

      it { is_expected.to eq('') }
    end
  end

  describe 'monthly?' do
    context 'monthly' do
      subject { general_sub_investment.monthly? }

      it { is_expected.to be_truthy }
    end

    context 'quarterly' do
      subject { customize_sub_investment(scheduled: 'Quarterly').monthly? }

      it { is_expected.to be_falsey }
    end
  end

  describe 'adjust_payment' do
    context 'accrued only' do
      let(:sub_investment) { create_sub_investment(per_annum: 0, accrued_per_annum: 2) }

      before do
        UpdateSubInvestmentPaymentService.new(sub_investment.id).call
      end

      it 'not include interest payment' do
        expect(sub_investment.payments.where(payment_kind: Payment::Type_Interest).count).to eq(0)
      end

      it 'include Accrued payment' do
        expect(sub_investment.payments.where(payment_kind: Payment::Type_Accrued).count).to be > 0
      end

      it 'include Principal' do
        expect(sub_investment.payments.where(payment_kind: Payment::Type_Principal).count).to be > 0
      end
    end

    context 'interest only' do
      context 'monthly' do
        let(:sub_investment) { create_sub_investment(per_annum: 12, accrued_per_annum: 0) }

        before do
          UpdateSubInvestmentPaymentService.new(sub_investment.id).call
        end

        it 'not include accrued payment' do
          expect(sub_investment.payments.where(payment_kind: Payment::Type_Accrued).count).to eq(0)
        end

        it 'include interest payment' do
          expect(sub_investment.payments.where(payment_kind: Payment::Type_Interest).count).to eq(13)
        end

        it 'interest payment date' do
          payments = sub_investment.payments.where(payment_kind: Payment::Type_Interest).order('due_date asc')
          expect(payments.first.due_date).to eq(Date.parse('2012-02-01'))
          expect(payments.last.due_date).to eq(Date.parse('2013-01-05'))
        end

        it 'interest amount' do
          payments = sub_investment.payments.where(payment_kind: Payment::Type_Interest).order('due_date asc')
          expect(payments.first.amount.to_s).to eq(format('%.2f', (12.0 / 365 / 100 * 27 * 1000))) # it is 27 days from 01-05 to 01-31
          expect(payments.last.amount.to_s).to eq(format('%.2f', (12.0 / 365 / 100 * 4 * 1000)))
          expect(format('%.2f', payments[1].amount.to_f)).to eq(format('%.2f', (12.0 / 365 / 100 * 30.4166 * 1000))) # one month is 30.4166 days
        end

        it 'include Principal' do
          expect(sub_investment.payments.where(payment_kind: Payment::Type_Principal).count).to be > 0
        end
      end

      context 'quarterly' do
        let(:sub_investment) do
          create_sub_investment({ per_annum: 12, accrued_per_annum: 0 }, { scheduled: 'Quarterly' })
        end

        before do
          UpdateSubInvestmentPaymentService.new(sub_investment.id).call
        end

        it 'include interest payment' do
          expect(sub_investment.payments.where(payment_kind: Payment::Type_Interest).count).to eq(5)
        end

        it 'interest payment date' do
          payments = sub_investment.payments.where(payment_kind: Payment::Type_Interest).order('due_date asc')
          expect(payments.first.due_date).to eq(Date.parse('2012-03-31'))
          expect(payments.last.due_date).to eq(Date.parse('2013-01-05'))
        end

        it 'interest amount' do
          payments = sub_investment.payments.where(payment_kind: Payment::Type_Interest).order('due_date asc')
          expect(payments.first.amount.to_s).to eq(format('%.2f', (12.0 / 365 / 100 * 86 * 1000))) # it is 86 days from 01-05 to 03-31
          expect(payments.last.amount.to_s).to eq(format('%.2f', (12.0 / 365 / 100 * 5 * 1000)))
          expect(format('%.2f', payments[1].amount.to_f)).to eq(format('%.2f', (12.0 / 365 / 100 * 91.25 * 1000))) # one quarter is 91.25 days
        end
      end
    end

    context 'with withdraw' do
      context 'one withdraw' do
        subject(:withdraw_payment) { sub_investment.payments.where(payment_kind: Payment::Type_Withdraw).first }

        let!(:sub_investment) { general_sub_investment }

        before do
          create(:withdraw, sub_investment: sub_investment, admin_user: sub_investment.admin_user, due_date: Date.parse('2012-02-25'))
          sub_investment.reload
          UpdateSubInvestmentPaymentService.new(sub_investment.id).call
        end

        it { is_expected.to_not be_nil }
        specify { withdraw_payment.amount.should eq(100) }
        specify { withdraw_payment.due_date.should eq(Date.parse('2012-02-25')) }

        # rubocop:disable RSpec/ExampleLength
        it 'interest payment' do
          payments = sub_investment.payments.where(payment_kind: Payment::Type_Interest).order('due_date asc')
          expect(payments.count).to eq(13) # count should not change
          expect(format('%.2f', payments[2].amount.to_f)).to eq(format('%.2f', (12.0 / 365 / 100 * 30.4166 * 900))) # sub-investment amount is 900 now
          # amount of the second interest
          expect(payments[1].amount).to be > format('%.2f', (12.0 / 365 / 100 * 30.4166 * 900)).to_f
          expect(payments[1].amount).to be < format('%.2f', (12.0 / 365 / 100 * 30.4166 * 1000)).to_f
          expect(payments[1].amount.to_s).to eq(format('%.2f', ((12.0 / 365 / 100 * 24 * 1000) + (12.0 / 365 / 100 * 5 * 900))))
        end
        # rubocop:enable RSpec/ExampleLength
      end

      context 'withdraw on a interest payment day' do
        let!(:sub_investment) { general_sub_investment }

        before do
          create(:withdraw, sub_investment: sub_investment, admin_user: sub_investment.admin_user, due_date: Date.parse('2012-03-01'))
          sub_investment.reload
          UpdateSubInvestmentPaymentService.new(sub_investment.id).call
        end

        it 'interest payment' do
          payments = sub_investment.payments.where(payment_kind: Payment::Type_Interest).order('due_date asc')
          expect(payments.count).to eq(13) # count should not change
          expect(format('%.2f', payments[1].amount.to_f)).to eq(format('%.2f', (12.0 / 365 / 100 * 30.4166 * 1000)))
          expect(format('%.2f', payments[2].amount.to_f)).to eq(format('%.2f', (12.0 / 365 / 100 * 30.4166 * 900))) # sub-investment amount is 900 now
        end
      end

      context 'two withdraws' do
        let!(:sub_investment) { general_sub_investment }

        before do
          create(:withdraw, sub_investment: sub_investment, admin_user: sub_investment.admin_user, due_date: Date.parse('2012-02-05'))
          create(:withdraw, sub_investment: sub_investment, admin_user: sub_investment.admin_user, due_date: Date.parse('2012-02-25'))
          sub_investment.reload
          UpdateSubInvestmentPaymentService.new(sub_investment.id).call
        end

        it 'include two withdraw payments' do
          expect(sub_investment.payments.where(payment_kind: Payment::Type_Withdraw).count).to eq(2)
        end

        it 'interest amount' do
          payments = sub_investment.payments.where(payment_kind: Payment::Type_Interest).order('due_date asc')
          expect(payments.count).to eq(13)
          expect(payments[1].amount.to_s).to eq(format('%.2f',
                                                       ((12.0 / 365 / 100 * 4 * 1000) + (12.0 / 365 / 100 * 20 * 900) + (12.0 / 365 / 100 * 5 * 800))))
        end
      end
    end

    context 'with referrand' do
      let!(:referrand_user) { create(:admin_user) }

      context 'monthly referrand' do
        let(:sub_investment) do
          customize_sub_investment(referrand_user_id: referrand_user.id, referrand_percent: 6,
                                   referrand_scheduled: 'Monthly')
        end

        before do
          UpdateSubInvestmentPaymentService.new(sub_investment.id).call
        end

        it 'include referrand payments' do
          expect(sub_investment.payments.where(payment_kind: Payment::Type_AMF).count).to eq(13)
        end
      end

      context 'quarterly referrand' do
        let(:sub_investment) do
          customize_sub_investment(referrand_user_id: referrand_user.id, referrand_percent: 6,
                                   referrand_scheduled: 'Quarterly')
        end

        before do
          UpdateSubInvestmentPaymentService.new(sub_investment.id).call
        end

        it 'include referrand payments' do
          expect(sub_investment.payments.where(payment_kind: Payment::Type_AMF).count).to eq(5)
        end
      end

      context 'fixed price referrand' do
        let(:sub_investment) do
          customize_sub_investment(referrand_user_id: referrand_user.id, referrand_one_time_amount: 100)
        end

        before do
          UpdateSubInvestmentPaymentService.new(sub_investment.id).call
        end

        it 'include referrand payments' do
          expect(sub_investment.payments.where(payment_kind: Payment::Type_AMF).count).to eq(1)
        end
      end
    end
  end

  describe 'pay' do
    let(:referrand_user) { create(:admin_user) }
    let(:sub_investment) do
      customize_sub_investment(referrand_user_id: referrand_user.id, referrand_percent: 6, referrand_scheduled: 'Monthly')
    end

    before do
      UpdateSubInvestmentPaymentService.new(sub_investment.id).call
    end

    context 'referrand' do
      subject(:payment) { sub_investment.pay(Time.zone.today, 100, 'referrand', referrand_user) }

      specify { payment.payment_kind.should eq(Payment::Type_AMF) }
      specify { payment.sub_investment.should eq(sub_investment) }
      specify { payment.amount.should eq(100) }
      specify { payment.due_date.should eq(calculate_payment_date(Time.zone.today)) }
    end

    context 'Principal' do
      subject { sub_investment.pay(Time.zone.today, 100, 'Principal Payback').payment_kind }

      it { is_expected.to eq(Payment::Type_Principal) }
    end

    context 'Withdraw' do
      subject { sub_investment.pay(Time.zone.today, 100, 'Withdraw').payment_kind }

      it { is_expected.to eq(Payment::Type_Withdraw) }
    end

    context 'Accrued' do
      subject { sub_investment.pay(Time.zone.today, 100, 'Accrued Payment').payment_kind }

      it { is_expected.to eq(Payment::Type_Accrued) }
    end

    context 'Interest' do
      subject { sub_investment.pay(Time.zone.today, 100, 'Interest').payment_kind }

      it { is_expected.to eq(Payment::Type_Interest) }
    end

    # context 'same payment kind on the same day' do
    #   subject { sub_investment.pay(Date.parse('2012-01-05'), 200, 'Interest') }

    #   let(:first_payment) { create(:payment, sub_investment: sub_investment) }

    #   it { is_expected.to eq(first_payment) }
    # end
  end

  describe 'customer_paid_payments' do
    let(:sub_investment) { general_sub_investment }

    before do
      UpdateSubInvestmentPaymentService.new(sub_investment.id).call
    end

    context 'without paid payments' do
      subject { sub_investment.customer_paid_payments }

      before do
        create_list(:payment, 2, sub_investment: sub_investment, admin_user: sub_investment.admin_user)
      end

      it { is_expected.to be_empty }
    end

    context 'with paid payments' do
      subject { sub_investment.customer_paid_payments.order('id') }

      let(:payment_list) do
        create_list(:payment, 2, sub_investment: sub_investment, admin_user: sub_investment.admin_user, paid: true)
      end

      it { is_expected.to eq(payment_list) }
    end
  end

  describe 'referrand_paid_payments' do
    let(:referrand_user) { create(:admin_user) }
    let(:sub_investment) do
      customize_sub_investment(referrand_user_id: referrand_user.id, referrand_percent: 6, referrand_scheduled: 'Monthly')
    end

    before do
      UpdateSubInvestmentPaymentService.new(sub_investment.id).call
    end

    context 'without paid referrand' do
      subject { sub_investment.referrand_paid_payments }

      before do
        create_list(:payment, 2, sub_investment: sub_investment, admin_user: referrand_user, payment_kind: Payment::Type_AMF)
      end

      it { is_expected.to be_empty }
    end

    context 'with paid referrand' do
      subject { sub_investment.referrand_paid_payments.order('id') }

      let(:payment_list) do
        create_list(:payment, 2, sub_investment: sub_investment, admin_user: referrand_user, payment_kind: Payment::Type_AMF, paid: true)
      end

      it { is_expected.to eq(payment_list) }
    end
  end

  describe 'without_referrand?' do
    subject { sub_investment.without_referrand? }

    let(:referrand_user) { create(:admin_user) }
    let(:sub_investment) do
      customize_sub_investment(referrand_user_id: referrand_user.id, referrand_percent: 6, referrand_scheduled: 'Monthly')
    end

    before do
      UpdateSubInvestmentPaymentService.new(sub_investment.id).call
    end

    context 'with referrand' do
      before do
        create_list(:payment, 2, sub_investment: sub_investment, admin_user: referrand_user, payment_kind: Payment::Type_AMF)
      end

      it { is_expected.to be_falsey }
    end

    context 'without referrand' do
      it { is_expected.to be_falsey }
    end
  end

  # describe "current_accrued" do
  #  context "without accrued payment" do
  #    let(:sub_investment) { create_sub_investment(accrued_per_annum: 0) }
  #    subject { sub_investment.current_accrued }
  #
  #    it { should eq(0) }
  #  end
  #
  #  context "with paid accrued payments" do
  #    let(:sub_investment) { general_sub_investment }
  #    before do
  #      sub_investment.reload
  #      sub_investment.payments.each { |p| p.paid = true and p.save }
  #    end
  #    subject { sub_investment.current_accrued }
  #    it { should eq(0)}
  #  end
  #
  #  context "with un paid accrued payments" do
  #    let(:sub_investment) { general_sub_investment }
  #
  #    context "today is before accrued_end_date" do
  #      let(:today) { Date.parse('2012-06-01') }
  #      before { Date.stub(:today) { today } }
  #
  #      it "have current accrued" do
  #        days = today - sub_investment.start_date
  #        payment = sub_investment.payments.where(payment_kind: Payment::Type_Accrued).first
  #        rate = payment.amount / (payment.due_date - sub_investment.start_date)
  #        expect(sub_investment.current_accrued.round(2)).to eq((days * rate).round(2))
  #      end
  #    end
  #
  #    context "today is after accrued_end_date" do
  #      let(:today) { Date.parse('2014-06-01') }
  #      before { Date.stub(:today) { today } }
  #
  #      it "have current accrued" do
  #        amount = sub_investment.payments.where(payment_kind: Payment::Type_Accrued).first.amount
  #        expect(sub_investment.current_accrued).to eq(amount)
  #      end
  #    end
  #  end
  # end

  describe 'status' do
    subject { sub_investment.status }

    let(:sub_investment) { general_sub_investment }

    it { is_expected.to eq('Active') }
  end
end
# rubocop:enable RSpec/NestedGroups
# rubocop:enable RSpec/NoExpectationExample
# rubocop:enable RSpec/MultipleExpectations
# rubocop:enable RSpec/AnyInstance
# rubocop:enable RSpec/ContextWording
