require File.expand_path('../boot', __FILE__)

require 'spreadsheet'
require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AppsMerconcoffee
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Central America'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :es

    require Rails.root.join("lib/custom_public_exceptions")
    config.exceptions_app = CustomPublicExceptions.new(Rails.public_path)

    # Bower asset paths
    config.assets.paths << Rails.root.join("vendor", "assets", "bower_components")
    config.assets.paths << Rails.root.join("vendor", "assets", "bower_components", "bootstrap-sass", "assets", "fonts", "bootstrap")
    config.assets.paths << Rails.root.join("vendor", "assets", "bower_components", "bootstrap-material-design", "dist", "css")
    config.assets.paths << Rails.root.join("vendor", "assets", "bower_components", "bootstrap-material-design", "dist", "js")
    # Precompile Bootstrap fonts
    config.assets.precompile << %r(bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff|woff2?)$)
    # Minimum Sass number precision required by bootstrap-sass
    # ::Sass::Script::Value::Number.precision = [8, ::Sass::Script::Value::Number.precision].max

    # config.assets.precompile << Proc.new { |path|
    #   if path =~ /\.(png)\z/
    #     full_path = Rails.application.assets.resolve(path).to_path
    #     app_assets_path = Rails.root.join('app', 'assets').to_path
    #     if full_path.starts_with? app_assets_path
    #       puts "including asset: " + full_path
    #       true
    #     else
    #       puts "excluding asset: " + full_path
    #       false
    #     end
    #   else
    #     false
    #   end
    # }
  end
end
