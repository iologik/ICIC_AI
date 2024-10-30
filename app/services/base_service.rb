# frozen_string_literal: true

class BaseService
  include ActionView::Helpers::NumberHelper

  def self.number_to_currency(value, options = { precision: 2 })
    (@base_service ||= BaseService.new).number_to_currency(value, options)
  end

  def self.number_to_percentage(value, options = { precision: 2 })
    (@base_service ||= BaseService.new).number_to_percentage(value, options)
  end
end
