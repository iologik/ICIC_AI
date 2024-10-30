# frozen_string_literal: true

# Generate Risk Acknowledgment for subinvestor

class RiskAcknowledgmentGenerateService
  attr_reader :investor

  MOVE_DOWN_POINT = 7

  def initialize(investor)
    @investor = investor
  end

  def call
    build_risk_acknowledgment!
  end

  def build_risk_acknowledgment!
    pdf_filename = "#{investor.id}-#{investor.name.parameterize}-agreement.pdf"
    pdf_handler  = CombinePDF.load(Rails.root.join('acknowledgment_sample.pdf').to_s)

    pdf_handler  = write_to_pdf(pdf_handler)
    # output the new pdf which now contains your dynamic data
    pdf_handler.save Rails.root.join(pdf_filename)

    pdf_filename
  end

  def write_to_pdf(pdf_handler)
    first_page      = pdf_handler.pages[0]
    investor_text   = "#{investor.reverse_name}  (\"Sub-Investor\")"
    investor_addrs  = "#{investor.address} #{investor.city} #{investor.province} #{investor.country}"

    # create a textbox and add it to the existing pdf on page 2
    first_page.textbox investor_text, height: 50, width: 310, y: 550, x: 82, font_size: 10, text_align: :left
    first_page.textbox investor_addrs, inline_format: true, height: 50, width: 310, y: 538, x: 82, font_size: 10, text_align: :left

    pdf_handler
  end
end
