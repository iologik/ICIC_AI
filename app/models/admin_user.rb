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
require 'validatable'

class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable
  include ICIC::Models::Validatable

  has_many :payments, dependent: :destroy
  has_many :sub_investments, dependent: :destroy

  has_one_attached :risk_acknowledgment
  has_one_attached :signed_risk_acknowledgment

  scope :order_by_name, -> { order(:last_name, :first_name) }
  scope :active, -> { order_by_name.where(status: 'active') }

  # validates :first_name, :presence => true
  validates :last_name, presence: true
  # rubocop:disable Rails/I18nLocaleTexts
  validates :pin, length: { maximum: 20 }, format: { with: /\A[A-Za-z0-9]*\z/, message: 'only allow letters and numbers' }
  # rubocop:enable Rails/I18nLocaleTexts

  after_initialize :set_default_status
  before_save :set_default_status

  def pwd
    password
  end

  def calc_investment_amount_usd
    sub_investments.usd.inject(0) { |r, sub| r + sub.amount }
  end

  def calc_investment_amount_cad
    sub_investments.cad.inject(0) { |r, sub| r + sub.amount }
  end

  def adjust_investment_amount
    update(investment_amount_usd: calc_investment_amount_usd)
    update(investment_amount_cad: calc_investment_amount_cad)
  end

  def name
    "#{last_name} #{first_name}"
  end

  def reverse_name
    "#{first_name} #{last_name}"
  end

  def relevant_users
    frelationship = SubInvestorRelationship.where('admin_user_id = :id or account_id = :id', id: id).first
    relationships = frelationship ? SubInvestorRelationship.where(admin_user_id: [frelationship.admin_user_id, frelationship.account_id]) : []

    accesses = []
    relationships.each do |relationship|
      accesses << relationship.admin_user_id
      accesses << relationship.account_id
    end
    accesses = accesses.uniq # can not use uniq!
    accesses.delete(id)
    accesses
  end

  def relevant_users_with_names
    ids = relevant_users
    names = []
    ids.each do |id|
      names << AdminUser.find(id).name
    end
    [ids, names]
  end

  def self.total
    total = 0
    Investment.find_each { |i| total += i.amount.to_i }
    total
  end

  def self.page_select
    results = []
    AdminUser.order_by_name.each do |admin_user|
      results << [admin_user.name, admin_user.id]
    end
    results
  end

  # rubocop:disable Security/Open
  def build_risk_acknowledgment
    file_name = RiskAcknowledgmentGenerateService.new(self).call
    file = open(file_name)
    risk_acknowledgment.purge
    risk_acknowledgment.attach(io: file, filename: file_name)

    FileUtils.rm_f(file_name)
  end
  # rubocop:enable Security/Open

  def upload_signed_acknowledgment(file)
    filename = "#{id}-#{name.parameterize}-acknowledgment-signed.pdf"
    signed_risk_acknowledgment.purge
    signed_risk_acknowledgment.attach(io: file, filename: filename)
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w(
      address admin city company_name country created_at current_sign_in_at current_sign_in_ip email
      encrypted_password first_name home_phone id investment_amount investment_amount_cad investment_amount_usd
      last_name last_sign_in_at last_sign_in_ip lif lira mobile_phone pin postal_code province
      remember_created_at reset_password_sent_at reset_password_token rif rrsp sign_in_count status updated_at
      work_phone
    )
  end

  def self.ransackable_associations(_auth_object = nil)
    %w(
      payments risk_acknowledgment_attachment risk_acknowledgment_blob signed_risk_acknowledgment_attachment
      signed_risk_acknowledgment_blob sub_investments
    )
  end

  private

  def set_default_status
    self.status ||= 'active'
  rescue
    # need status field is migrated
  end
end
