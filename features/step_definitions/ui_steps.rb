# frozen_string_literal: true

Given(/^I am User "(.*?)"$/) do |email|
  @user = AdminUser.create!(email:, password: 'password123!', password_confirmation: 'password123!')
end

Given(/^I am a regular user$/) do
  @user.admin = false
  @user.save
end

Given(/^I am an admin user$/) do
  @user.admin = true
  @user.save
end

When(/^I visit "(.*?)" url$/) do |arg1|
  visit arg1
  url = URI.parse(current_url).to_s # .path.should == path_to(arg1)
  url.include?(arg1).should == true
end

# Given(/^I visit "(.*?)"$/) do |arg1|
#  visit arg1
#  puts URI.parse(current_url) #.path.should == path_to(arg1)
# end

Then(/^I should be on page "(.*?)"$/) do |arg1|
  URI.parse(current_url).to_s.include? arg1
end

When(/^I login with "(.*?)" , "(.*?)"$/) do |arg1, arg2|
  visit '/admin/login'
  fill_in('admin_user_email', with: arg1)
  fill_in('admin_user_password', with: arg2)
  click_button('Login')
end

Then(/^I should be on the dashboard$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be on the login page$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see error "(.*?)"$/) do |_arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see the total line$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I have the following payments:$/) do |_table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

Given(/^I export to quickbooks$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should have a CSV file$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^it should have (\d+) lines$/) do |_arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^it should line with "(.*?)"$/) do |_arg1|
  pending # express the regexp above with the code you wish you had
end
