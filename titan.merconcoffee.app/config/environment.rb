# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Load active directory YML file
APP_ACTIVE_DIRECTORY = YAML.load_file(Rails.root.join('config', 'active_directory.yml'))

# Load service YML file
APP_SERVICE = YAML.load_file(Rails.root.join('config', 'service.yml'))
