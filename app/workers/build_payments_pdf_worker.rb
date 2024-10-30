# frozen_string_literal: true

class BuildPaymentsPDFWorker
  include Sidekiq::Worker
  include Redisable

  def perform(id, receiver_email)
    payment_ids = redis.get(id).split(', ')
    payments    = Payment.where(id: payment_ids)
    pdf         = BuildPaymentsPDFService.new.call(payments).render
    all_payments = payments.length == Payment.count
    if pdf.size > 15.megabytes # upload to S3
      send_email_with_link(pdf, receiver_email, all_payments)
    else
      AdminMailer.payments_pdf_email(receiver_email, pdf, all_payments, false).deliver
    end
  end

  def send_email_with_link(pdf, receiver_email, all_payments)
    public_url = upload_file(pdf, "payments-#{Time.now.to_i}.pdf")

    AdminMailer.payments_pdf_email(receiver_email, public_url, all_payments, true).deliver
  end

  def upload_file(content, key)
    path   = Rails.root.join('config', 'storage.yml')
    config = YAML.safe_load_file(path)

    credentials = Aws::Credentials.new(ENV.fetch('aws_access_key_id', nil), ENV.fetch('aws_secret_access_key', nil))

    s3  = Aws::S3::Resource.new(region: config['amazon']['region'], credentials: credentials)
    obj = s3.bucket(ENV.fetch('bucket', nil)).object(key)
    obj.put({ body: content })
    obj.public_url
  end
end
