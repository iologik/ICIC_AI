# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

# rubocop:disable Metrics/BlockLength
ActiveRecord::Schema.define(version: 20_230_920_175_322) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'pg_stat_statements'
  enable_extension 'plpgsql'

  create_table 'accounts', id: :serial, force: :cascade do |t|
    t.string 'name', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'active_admin_comments', id: :serial, force: :cascade do |t|
    t.string 'resource_id', limit: 255, null: false
    t.string 'resource_type', limit: 255, null: false
    t.integer 'author_id'
    t.string 'author_type', limit: 255
    t.text 'body'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'namespace', limit: 255
    t.index %w[author_type author_id], name: 'index_active_admin_comments_on_author_type_and_author_id'
    t.index ['namespace'], name: 'index_active_admin_comments_on_namespace'
    t.index %w[resource_type resource_id], name: 'index_admin_notes_on_resource_type_and_resource_id'
  end

  create_table 'active_storage_attachments', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'record_type', null: false
    t.bigint 'record_id', null: false
    t.bigint 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness',
                                                    unique: true
  end

  create_table 'active_storage_blobs', force: :cascade do |t|
    t.string 'key', null: false
    t.string 'filename', null: false
    t.string 'content_type'
    t.text 'metadata'
    t.bigint 'byte_size', null: false
    t.string 'checksum', null: false
    t.datetime 'created_at', null: false
    t.string 'service_name', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_variant_records', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.string 'variation_digest', null: false
    t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end

  create_table 'admin_users', id: :serial, force: :cascade do |t|
    t.string 'email', limit: 255, default: '', null: false
    t.string 'encrypted_password', limit: 255, default: '', null: false
    t.string 'reset_password_token', limit: 255
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer 'sign_in_count', default: 0, null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.string 'current_sign_in_ip', limit: 255
    t.string 'last_sign_in_ip', limit: 255
    t.string 'first_name', limit: 255
    t.string 'last_name', limit: 255
    t.string 'home_phone', limit: 255
    t.string 'work_phone', limit: 255
    t.string 'mobile_phone', limit: 255
    t.string 'address', limit: 255
    t.string 'city', limit: 255
    t.string 'province', limit: 255
    t.string 'country', limit: 255
    t.string 'postal_code', limit: 255
    t.boolean 'admin'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'rrsp', limit: 255
    t.string 'rif', limit: 255
    t.string 'lif', limit: 255
    t.string 'lira', limit: 255
    t.string 'company_name', limit: 255
    t.string 'status'
    t.decimal 'investment_amount', precision: 12, scale: 2
    t.decimal 'investment_amount_usd'
    t.decimal 'investment_amount_cad'
    t.string 'pin'
    t.index ['reset_password_token'], name: 'index_admin_users_on_reset_password_token', unique: true
  end

  create_table 'borrowers', id: :serial, force: :cascade do |t|
    t.string 'first_name', limit: 255
    t.string 'last_name', limit: 255
    t.string 'email', limit: 255
    t.string 'company', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'distributions', id: :serial, force: :cascade do |t|
    t.decimal 'return_of_capital', precision: 12, scale: 2
    t.decimal 'gross_profit', precision: 12, scale: 2
    t.date 'date'
    t.text 'description'
    t.integer 'investment_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.decimal 'withholding_tax', precision: 12, scale: 2
    t.decimal 'holdback_state', precision: 12, scale: 2
    t.decimal 'cash_reserve', precision: 12, scale: 2
  end

  create_table 'draws', id: :serial, force: :cascade do |t|
    t.decimal 'amount', precision: 12, scale: 2
    t.date 'date'
    t.text 'description'
    t.integer 'investment_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'events', id: :serial, force: :cascade do |t|
    t.date 'date'
    t.text 'description'
    t.integer 'sub_investment_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'exchange_rates', id: :serial, force: :cascade do |t|
    t.date 'date'
    t.decimal 'usd_to_cad_rate'
    t.decimal 'cad_to_usd_rate'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'fees', force: :cascade do |t|
    t.bigint 'sub_investment_id'
    t.bigint 'investment_id'
    t.string 'description'
    t.decimal 'amount'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'collected', default: false
    t.bigint 'withdraw_id'
    t.index ['investment_id'], name: 'index_fees_on_investment_id'
    t.index ['sub_investment_id'], name: 'index_fees_on_sub_investment_id'
    t.index ['withdraw_id'], name: 'index_fees_on_withdraw_id'
  end

  create_table 'interest_periods', id: :serial, force: :cascade do |t|
    t.date 'effect_date'
    t.decimal 'per_annum'
    t.decimal 'accrued_per_annum'
    t.integer 'sub_investment_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.decimal 'retained_per_annum'
  end

  create_table 'investment_kinds', id: :serial, force: :cascade do |t|
    t.string 'name', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'investment_sources', id: :serial, force: :cascade do |t|
    t.string 'name', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'priority'
    t.string 'pin'
  end

  create_table 'investment_statuses', id: :serial, force: :cascade do |t|
    t.string 'name', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'investments', id: :serial, force: :cascade do |t|
    t.string 'name', limit: 255
    t.integer 'investment_kind_id'
    t.decimal 'amount', precision: 12, scale: 2
    t.text 'description'
    t.string 'image_url', limit: 255
    t.integer 'investment_status_id'
    t.float 'exchange_rate'
    t.integer 'investment_source_id'
    t.float 'expected_return_percent'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.text 'private_note'
    t.decimal 'year_paid'
    t.decimal 'ori_amount', precision: 12, scale: 2
    t.date 'start_date'
    t.string 'currency', limit: 255
    t.string 'address', limit: 255
    t.string 'legal_name', limit: 255
    t.string 'location', limit: 255
    t.date 'archive_date'
    t.string 'fee_type'
    t.decimal 'fee_amount'
    t.string 'memo', limit: 120
    t.text 'initial_description'
    t.decimal 'money_raised_amount', precision: 12, scale: 2
    t.decimal 'cash_reserve_amount', precision: 12, scale: 2
    t.decimal 'cad_money_raised_amount', precision: 12, scale: 2
    t.decimal 'icic_committed_capital'
    t.decimal 'sub_amount_total'
    t.decimal 'sub_ownership_percent_sum'
    t.decimal 'sub_per_annum_sum'
    t.decimal 'sub_accrued_percent_sum'
    t.decimal 'sub_retained_percent_sum'
    t.decimal 'distrib_return_of_capital'
    t.decimal 'distrib_withholding_tax'
    t.decimal 'distrib_holdback_state'
    t.decimal 'distrib_gross_profit'
    t.decimal 'distrib_cash_reserve'
    t.decimal 'distrib_net_cash'
    t.decimal 'draw_amount'
    t.decimal 'distribution_draw_amount'
    t.decimal 'accrued_payable_amount'
    t.decimal 'retained_payable_amount'
    t.decimal 'gross_profit_total_amount'
    t.decimal 'all_paid_payments_amount'
    t.decimal 'sub_balance_amount'
    t.decimal 'net_income_amount'
    t.string 'postal_code'
    t.index ['investment_kind_id'], name: 'index_investments_on_investment_kind_id'
    t.index ['investment_source_id'], name: 'index_investments_on_investment_source_id'
    t.index ['investment_status_id'], name: 'index_investments_on_investment_status_id'
  end

  create_table 'letsencrypt_plugin_challenges', id: :serial, force: :cascade do |t|
    t.text 'response'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'loan_draws', id: :serial, force: :cascade do |t|
    t.integer 'loan_id'
    t.float 'amount'
    t.date 'due_date'
    t.string 'check_no', limit: 255
    t.string 'type', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'loan_interest_periods', id: :serial, force: :cascade do |t|
    t.date 'effect_date'
    t.decimal 'per_annum'
    t.integer 'loan_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'loan_payments', id: :serial, force: :cascade do |t|
    t.integer 'loan_id'
    t.integer 'borrower_id'
    t.integer 'cash_back_id'
    t.string 'payment_kind', limit: 255
    t.date 'due_date'
    t.string 'check_no', limit: 255
    t.string 'memo', limit: 255
    t.boolean 'paid', default: false
    t.decimal 'amount', precision: 12, scale: 2
    t.date 'start_date'
    t.text 'remark'
    t.decimal 'loan_amount', precision: 12, scale: 2
    t.string 'currency', limit: 255
    t.decimal 'rate', precision: 12, scale: 2
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'loans', id: :serial, force: :cascade do |t|
    t.integer 'borrower_id'
    t.decimal 'ori_amount', precision: 12, scale: 2
    t.decimal 'amount', precision: 12, scale: 2
    t.date 'start_date'
    t.string 'currency', limit: 255
    t.string 'scheduled', limit: 255
    t.integer 'months'
    t.text 'description'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'name', limit: 255
  end

  create_table 'payments', id: :serial, force: :cascade do |t|
    t.integer 'sub_investment_id'
    t.integer 'admin_user_id'
    t.date 'due_date'
    t.decimal 'amount', precision: 12, scale: 2
    t.text 'memo'
    t.string 'payment_kind', limit: 255
    t.string 'check_no', limit: 255
    t.boolean 'paid', default: false, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.date 'start_date'
    t.integer 'withdraw_id'
    t.text 'remark'
    t.string 'source_flag', limit: 255
    t.decimal 'sub_investment_amount', precision: 12, scale: 2
    t.decimal 'rate'
    t.string 'currency', limit: 255
    t.string 'sub_investor_name'
    t.string 'investment_name'
    t.boolean 'is_resend_statement'
    t.date 'paid_date'
    t.index ['admin_user_id'], name: 'index_payments_on_admin_user_id'
    t.index ['sub_investment_id'], name: 'index_payments_on_sub_investment_id'
    t.index ['withdraw_id'], name: 'index_payments_on_withdraw_id'
  end

  create_table 'post_images', id: :serial, force: :cascade do |t|
    t.string 'file', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'posts', id: :serial, force: :cascade do |t|
    t.string 'title', limit: 255
    t.text 'body'
    t.integer 'investment_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'email_sub_investor'
  end

  create_table 'sub_distributions', id: :serial, force: :cascade do |t|
    t.integer 'sub_investment_id'
    t.decimal 'amount', precision: 12, scale: 2
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.date 'date'
    t.integer 'admin_user_id'
    t.integer 'transfer_to_id'
    t.string 'sub_distribution_type', limit: 255
    t.boolean 'is_notify_investor'
    t.string 'check_no'
    t.decimal 'origin_amount'
    t.decimal 'target_amount'
    t.index ['transfer_to_id'], name: 'index_sub_distributions_on_transfer_to_id'
  end

  create_table 'sub_investments', id: :serial, force: :cascade do |t|
    t.integer 'admin_user_id'
    t.integer 'investment_id'
    t.string 'scheduled', limit: 255
    t.integer 'months'
    t.decimal 'amount', precision: 12, scale: 2
    t.string 'currency', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'referrand_user_id'
    t.float 'referrand_percent'
    t.decimal 'referrand_one_time_amount', precision: 12, scale: 2
    t.float 'referrand_amount'
    t.string 'referrand_scheduled', limit: 255
    t.decimal 'ori_amount', precision: 12, scale: 2
    t.text 'description'
    t.date 'referrand_one_time_date'
    t.integer 'account_id'
    t.integer 'investment_status_id'
    t.integer 'transfer_from_id'
    t.text 'private_note'
    t.string 'remote_agreement_url'
    t.decimal 'exchange_rate'
    t.string 'name', default: ''
    t.string 'signed_agreement_url'
    t.string 'memo', limit: 120
    t.text 'initial_description'
    t.string 'sub_investment_source_id'
    t.string 'sub_investment_kind_id'
    t.boolean 'is_notify_investor'
    t.date 'archive_date'
    t.date 'creation_date'
    t.string 'envelope_id'
    t.decimal 'current_accrued_amount'
    t.decimal 'current_retained_amount'
    t.index ['account_id'], name: 'index_sub_investments_on_account_id'
    t.index ['admin_user_id'], name: 'index_sub_investments_on_admin_user_id'
    t.index ['investment_id'], name: 'index_sub_investments_on_investment_id'
    t.index ['investment_status_id'], name: 'index_sub_investments_on_investment_status_id'
    t.index ['transfer_from_id'], name: 'index_sub_investments_on_transfer_from_id'
  end

  create_table 'sub_investor_relationships', id: :serial, force: :cascade do |t|
    t.integer 'admin_user_id'
    t.integer 'account_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['account_id'], name: 'index_sub_investor_relationships_on_account_id'
  end

  create_table 'tasks', id: :serial, force: :cascade do |t|
    t.date 'date'
    t.text 'description'
    t.string 'status', limit: 255
    t.integer 'sub_investment_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'variables', force: :cascade do |t|
    t.string 'key'
    t.string 'value'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'versions', id: :serial, force: :cascade do |t|
    t.string 'item_type', limit: 255, null: false
    t.integer 'item_id', null: false
    t.string 'event', limit: 255, null: false
    t.string 'whodunnit', limit: 255
    t.text 'object'
    t.datetime 'created_at'
    t.index %w[item_type item_id], name: 'index_versions_on_item_type_and_item_id'
  end

  create_table 'withdraws', id: :serial, force: :cascade do |t|
    t.integer 'admin_user_id'
    t.integer 'sub_investment_id'
    t.decimal 'amount', precision: 12, scale: 2
    t.date 'due_date'
    t.string 'check_no', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'type', limit: 255
    t.boolean 'is_transfer', default: false
    t.integer 'transfer_to_id'
    t.integer 'transfer_from_id'
    t.boolean 'paid', default: false
    t.boolean 'is_notify_to_investor'
    t.date 'paid_date'
    t.boolean 'is_notify_investor'
    t.index ['admin_user_id'], name: 'index_withdraws_on_admin_user_id'
    t.index ['sub_investment_id'], name: 'index_withdraws_on_sub_investment_id'
    t.index ['transfer_from_id'], name: 'index_withdraws_on_transfer_from_id'
    t.index ['transfer_to_id'], name: 'index_withdraws_on_transfer_to_id'
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
end
# rubocop:enable Metrics/BlockLength
