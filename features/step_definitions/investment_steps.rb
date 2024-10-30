# frozen_string_literal: true

Given(/^I have Investment of \$(\d+)$/) do |amount|
  Investment.destroy_all
  SubInvestment.destroy_all
  Withdraw.destroy_all
  Payment.destroy_all
  @investment = Investment.create!(name: 'some investment', amount:, money_raised: 0)
end

Given(/^I subinvest \$(\d+)$/) do |amount|
  @subinvestment = SubInvestment.create!(
    investment_id: @investment.id,
    amount:, admin_user_id: 1,
    start_date: Time.zone.today, months: 12,
    scheduled: 'Monthly', per_annum: 12, accrued_per_annum: 11
  )
  @investment.reload
end

Given(/^I withdraw \$(\d+)$/) do |arg1|
  @withdraw = Withdraw.new(sub_investment_id: @subinvestment.id, amount: arg1, due_date: Time.zone.today)
  @withdraw.save
  @withdraw.adjust_payments
  @investment.reload
end

Given(%r{^I withdraw \$(\d+) due on (\d+)/(\d+)/(\d+)$}) do |amount, dd, mm, yy|
  @withdraw = Withdraw.new(sub_investment_id: @subinvestment.id, amount:,
                           due_date: Date.parse("#{yy}-#{mm}-#{dd}"))
  @withdraw.save
  @subinvestment.reload
  @investment.reload
end

Given(/^the invest is for period of (\d+) months$/) do |arg1|
  @subinvestment.months = arg1
  @subinvestment.save
end

Given(/^the payment schedule is quarterly$/) do
  @subinvestment.scheduled = 'Quarterly'
  @subinvestment.save
end

Given(/^the start date  is  (\d+)-(\d+)-(\d+)$/) do |yy, mm, dd|
  ss = "#{yy}-#{mm}-#{dd}"
  @subinvestment.start_date = Date.parse(ss)
  @subinvestment.save
end

Given(/^the per_annum rate is (\d+)%$/) do |arg1|
  @subinvestment.per_annum = arg1
  @subinvestment.save
end

Given(/^the accrued_per_annum rate is (\d+)%$/) do |arg1|
  @subinvestment.accrued_per_annum = arg1
  @subinvestment.save
end

Given(/^I create payments$/) do
  @subinvestment.adjust_payment
end

Then(/^the investment money raised should be \$(\d+)$/) do |arg1|
  @investment.reload
  @investment.money_raised.to_i.should eq arg1.to_i
end

Given(/^the referand gets \$(\d+)$/) do |arg1|
  @referand = AdminUser.create!(email: 'referand@gmail.com', password: 'referand123',
                                password_confirmation: 'referand123', name: 'referand')
  @subinvestment.refferand_one_time_amount = arg1
  @subinvestment.refferand_user_id = @referand.id
  @subinvestment.save
end

Given(/^the referand gets (\d+)%$/) do |arg1|
  @referand = AdminUser.create!(email: 'referand@gmail.com', password: 'referand123',
                                password_confirmation: 'referand123', name: 'referand')
  @subinvestment.refferand_percent = arg1
  @subinvestment.refferand_user_id = @referand.id
  @subinvestment.save
end

Then(/^I should have (\d+) payments$/) do |arg1|
  @subinvestment.payments.each do |p|
    puts p.inspect
    puts '---'
  end
  @subinvestment.payments.count.should eq arg1.to_i
end

Then(%r{^I should have payment of \$(\d+)\.(\d+)  due on  (\d+)/(\d+)/(\d+)$}) do |dollars, cents, dd, mm, yy|
  p = @subinvestment.payments.find_by_amount_and_due_date("#{dollars}.#{cents}", "#{yy}-#{mm}-#{dd}")
  p.should_not be_nil
end

Then(/^I should have (\d+) withdraws$/) do |arg1|
  @subinvestment.withdraws.count.should eq arg1.to_i
end

Given(/^I have SubInvestment of \$(\d+)$/) do |amount|
  @investment = Investment.create!(name: 'Milion Dollar Investment', amount: '1000000', money_raised: 0)
  @subinvestment = SubInvestment.create!(
    investment_id: @investment.id,
    amount:, admin_user_id: 1,
    start_date: Time.zone.today, months: 12,
    scheduled: 'Monthly', per_annum: 12, accrued_per_annum: 11
  )
  @investment.reload
end

Given(/^there is a referral$/) do
  @referral = AdminUser.create!(email: 'referral123@gmail.com', password: 'password123!',
                                password_confirmation: 'password123!')
  @subinvestment.referrand_user_id = @referral.id
  @subinvestment.save
end

Given(/^the referral is paid \$(\d+) one time on (.*)$/) do |amount, date|
  @subinvestment.referrand_one_time_amount = amount
  @subinvestment.referrand_one_time_date = Date.parse(date)
  @subinvestment.save
  @investment.reload
end

Then(/^the referral should have 1 payment of \$(\d+) due to (.*)$/) do |arg1, arg2|
  payments = @subinvestment.payments.where(payment_kind: Payment::Type_AMF)
  payments.count.should
  payments.first.amount.should
  arg1.to_f
  payments.first.due_date.should == Date.parse(arg2)
end

Given(/^the referral is paid \$(\d+) monthly$/) do |arg1|
  @subinvestment.referrand_amount = arg1
  @subinvestment.referrand_scheduled = 'Monthly'
  @subinvestment.save
  @investment.reload
end

Then(/^the referral should have (\d+) payments of about \$(\d+)$/) do |_arg1, arg2|
  payments = @subinvestment.payments.where(payment_kind: Payment::Type_AMF)
  payments.count.to_s.should
  total_amount = payments.inject(0) do |r, v|
    r += v.amount
    r
  end
  # because the AMF payment is calculated by month, so there is a deviation, I think the deviation will be within 1%
  # (compare to sub_investment amount * AMF_percet)
  ((total_amount - arg2.to_f) / arg2.to_f).should < 0.01
end

Given(/^the referral is paid (\d+)% monthly$/) do |arg1|
  @subinvestment.referrand_percent = arg1
  @subinvestment.referrand_scheduled = 'Monthly'
  @subinvestment.save
  @investment.reload
end

Given(/^the referral is paid \$(\d+) quarterly$/) do |_arg1|
  @subinvestment.referrand_scheduled = 'Quarterly'
  @subinvestment.save
  @investment.reload
end

Given(/^the referral is paid (\d+)% quarterly$/) do |arg1|
  @subinvestment.referrand_percent = arg1
  @subinvestment.referrand_scheduled = 'Quarterly'
  @subinvestment.save
  @investment.reload
end

When(/^I visit "(.*?)"$/) do |_arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^there should be (\d+) payments$/) do |arg1|
  @subinvestment.payments.count.should == arg1.to_i
end

Then(/^I should have (\d+) interest payments$/) do |arg1|
  @subinvestment.payments.interest.count.should == arg1.to_i
end

Then(/^I should have (\d+) principle payments$/) do |arg1|
  @subinvestment.payments.principle.count.should == arg1.to_i
end
