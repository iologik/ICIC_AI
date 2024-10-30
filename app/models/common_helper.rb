# frozen_string_literal: true

class CommonHelper
  include ActionView::Helpers::NumberHelper

  def self.number_to_currency(value, options = { precision: 2 })
    (@common_helper ||= CommonHelper.new).number_to_currency(value, options)
  end
end
