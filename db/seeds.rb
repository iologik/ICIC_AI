# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

AdminUser.delete_all
AdminUser.create!(email: 'itamardavid@gmail.com', first_name: 'Itamar', last_name: 'David',
                  password: 'password', password_confirmation: 'password', admin: true, pin: '1234')
AdminUser.create!(email: 'assaf.goldstein@gmail.com', first_name: 'Assaf', last_name: 'Goldstein',
                  password: 'clipper123', password_confirmation: 'clipper123', admin: true, pin: '2345')
AdminUser.create!(email: 'user1@example.com', first_name: 'David', last_name: 'Gallan',
                  password: 'password', password_confirmation: 'password', pin: 'abcd')
AdminUser.create!(email: 'user2@example.com', first_name: 'Roger', last_name: 'waters',
                  password: 'password', password_confirmation: 'password', pin: 'efw3')

user_names = %(Albert Amar
Alexander Hayne
Carol Lenard
Dawn Gareau
Dagne Fortin
Barbara Burrows
Capital Maxx
David Diane
Carol Paul Jensen
Ergo Systems (ulrika)
Ellis Burrows
Evelyn Amar
Gerald DeCario
Itamar David
Ilana Leviton
Katelyn Fortin
Karl Spielman
Matthias Hammer
Margaret Gabriel
Delia van Haren
Murray Munro
Monty Reitzik
Peter Wieser
Paul Jensen tax
Raffi Reitzik
Ran Kohavi
Roger Ramsumair
Nancy Travis
Micheal Travis
David Van Haren
Nyala Van Haren
Rhonda Van Haren
Ryan Van Haren
Santichai Kowong
Shlomo Friedman
Ulrika Wallersteiner
Errol Lipshit
Mary Ellen Boyd
Katlyn Fortin
Innovation Capital Investment Corp
)

user_names.split("\n").each do |name|
  name_arr = name.split
  AdminUser.create!(email: "#{name_arr.join('_').downcase}@example.com", first_name: name_arr[0],
                    last_name: name_arr[-1], password: 'password', password_confirmation: 'password', pin: '12344')
end

InvestmentKind.delete_all
InvestmentKind.create!(name: 'Realestate')
InvestmentKind.create!(name: 'Loans')
InvestmentKind.create!(name: 'Startup')

InvestmentSource.delete_all
InvestmentSource.create!(name: 'Ender', priority: 1)
InvestmentSource.create!(name: 'Imor', priority: 2)
InvestmentSource.create!(name: 'Pahlisch', priority: 3)
InvestmentSource.create!(name: 'ICIC', priority: 4)
InvestmentSource.create!(name: 'Simac', priority: 5)
InvestmentSource.create!(name: 'D&D', priority: 6)
InvestmentSource.create!(name: 'SL', priority: 7)

InvestmentStatus.delete_all
InvestmentStatus.create!(name: 'Active')
InvestmentStatus.create!(name: 'Archived')

Investment.delete_all
# Investment.create!(name: 'Achesson', amount: '300000', expected_return_percent: '10',
#                    investment_source_id: icic.id, investment_status_id: InvestmentStatus.first.id, investment_kind_id: InvestmentKind.first.id, start_date: Time.now)
# Investment.create!(name: 'Action Steel', amount: '304024', expected_return_percent: '8',
#                    investment_source_id: icic.id, investment_status_id: InvestmentStatus.first.id, investment_kind_id: InvestmentKind.first.id, start_date: Time.now)
# Investment.create!(name: 'Awbry Woods', amount: '308826', expected_return_percent: '30',
#                    investment_source_id: icic.id, investment_status_id: InvestmentStatus.first.id, investment_kind_id: InvestmentKind.first.id, start_date: Time.now)
# Investment.create!(name: 'Awbry Building Loans', amount: '155785', expected_return_percent: '12',
#                    investment_source_id: icic.id, investment_status_id: InvestmentStatus.first.id, investment_kind_id: InvestmentKind.first.id, start_date: Time.now)
# Investment.create!(name: 'Bailey Ridge', amount: '650000', expected_return_percent: '26',
#                    investment_source_id: icic.id, investment_status_id: InvestmentStatus.first.id, investment_kind_id: InvestmentKind.first.id, start_date: Time.now)
# Investment.create!(name: 'Bell Road', amount: '62500', expected_return_percent: '15',
#                    investment_source_id: icic.id, investment_status_id: InvestmentStatus.first.id, investment_kind_id: InvestmentKind.first.id, start_date: Time.now)
# Investment.create!(name: 'Brodie', amount: '131000', expected_return_percent: '26',
#                    investment_source_id: icic.id, investment_status_id: InvestmentStatus.first.id, investment_kind_id: InvestmentKind.first.id, start_date: Time.now)
# Investment.create!(name: 'CY Logistics', amount: '208142', expected_return_percent: '12',
#                    investment_source_id: icic.id, investment_status_id: InvestmentStatus.first.id, investment_kind_id: InvestmentKind.first.id, start_date: Time.now)
# Investment.create!(name: 'Imor Investment', amount: '100000', expected_return_percent: '12',
#                    investment_source_id: imor.id, investment_status_id: InvestmentStatus.first.id, investment_kind_id: InvestmentKind.first.id, start_date: Time.now)
# Investment.create!(name: 'Foothill View', amount: '510000', expected_return_percent: '37',
#                    investment_source_id: icic.id, investment_status_id: InvestmentStatus.first.id, investment_kind_id: InvestmentKind.first.id, start_date: Time.now)

Account.delete_all
Account.create(name: 'RIF')
Account.create(name: 'RRSP')
Account.create(name: 'LIF')
Account.create(name: 'LIRA')

SubInvestment.delete_all
Withdraw.delete_all
Payment.delete_all

ExchangeRate.create(date: Time.zone.today, usd_to_cad_rate: 1.36, cad_to_usd_rate: 0.74)
