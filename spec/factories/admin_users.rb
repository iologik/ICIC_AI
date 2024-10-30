# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_users
#
#  id                     :integer          not null, primary key
#  address                :string(255)
#  admin                  :boolean
#  city                   :string(255)
#  company_name           :string(255)
#  country                :string(255)
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  first_name             :string(255)
#  home_phone             :string(255)
#  investment_amount      :decimal(12, 2)
#  investment_amount_cad  :decimal(, )
#  investment_amount_usd  :decimal(, )
#  last_name              :string(255)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  lif                    :string(255)
#  lira                   :string(255)
#  mobile_phone           :string(255)
#  pin                    :string
#  postal_code            :string(255)
#  province               :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  rif                    :string(255)
#  rrsp                   :string(255)
#  sign_in_count          :integer          default(0), not null
#  status                 :string
#  work_phone             :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_admin_users_on_reset_password_token  (reset_password_token) UNIQUE
#
FactoryBot.define do
  sequence(:email) { |n| "person_#{n}@example.com" }

  factory :admin_user do
    email { generate(:email) }
    password { 'password' }
    password_confirmation { 'password' }
    first_name { 'first name' }
    last_name { 'last name' }
  end
end
