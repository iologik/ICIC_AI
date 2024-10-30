# frozen_string_literal: true

module ApplicationHelper
  # add active admin helper here, and restart the app
  def generate_url(current_url, page: 1, report: false)
    return if report

    url = current_url.gsub(/page=\d+/, '')
    if url.include?('?')
      url + "&page=#{page}"
    else
      url + "?page=#{page}"
    end
  end

  def source_flag_of(report_id)
    T5Report.find(report_id).source_flag
  end
end
