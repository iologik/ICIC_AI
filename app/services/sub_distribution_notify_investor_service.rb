# frozen_string_literal: true

class SubDistributionNotifyInvestorService
  attr_accessor :sub_distribution

  def call(sub_distribution_id)
    return unless SubDistribution.exists? sub_distribution_id

    @sub_distribution = SubDistribution.find(sub_distribution_id)

    pdf_handler       = BuildSubDistributionService.new.call(sub_distribution, sub_distribution.skip_make_payment_or_transfer)
    fullname          = render_filename
    pdf_handler.render_file fullname
    SubDistributionMailer.transfer(sub_distribution, sanitized_name, sub_distribution.target_emails).deliver
    File.delete(fullname)
  end

  def render_filename
    "#{sanitized_name}.pdf"
  end

  def sanitized_name
    ActiveStorage::Filename.new(filename).sanitized
  end

  def filename
    "#{sub_distribution.admin_user.name}'s transfer from #{sub_distribution.sub_investment.name} to #{sub_distribution.transfer_to.name}"
  end
end
