require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.setup(:default, Rails.env)

require 'dotenv-rails' if Rails.env.in?(%w[test development])
require 'sublime_video_private_api'
require 'librato-rails'
require 'newrelic_rpm'
require 'honeybadger/railtie'

module VideosSublimeVideo
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.active_record.schema_format = :sql

    # Disable the asset pipeline.
    config.assets.enabled = false
  end
end

# Ensure tmp folder
temp_dir = Rails.root.join('tmp')
Dir.mkdir(temp_dir) unless Dir.exists?(temp_dir)
