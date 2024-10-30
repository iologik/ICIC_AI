# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Icic
  class Application < Rails::Application
    config.time_zone = 'Mountain Time (US & Canada)'
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.action_mailer.default_url_options = { host: 'www.innovationcic.com' }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.assets.precompile += ['pdf.css']
    config.assets.paths << Rails.root.join('app', 'assets', 'images')
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    config.hosts.clear
    config.active_storage.service_urls_expire_in = 1.day

    Prawn::Fonts::AFM.hide_m17n_warning = true
  end
end
