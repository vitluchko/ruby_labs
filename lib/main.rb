# frozen_string_literal: true

# Import necessary files
require_relative 'app_config_loader'
require_relative 'vitluchko_application'

# Initialize the Configurator with default configuration
configurator = VitluchkoApplication::Configurator.new

# Load configurations using the configurator (this simulates the loading of config data)
configurator.configure(
  run_website_parser: 1,      # Enable website parsing
  run_save_to_csv: 1,         # Enable saving to CSV
  run_save_to_json: 1,        # Enable saving to JSON
  run_save_to_yaml: 1,        # Disable saving to YAML
  run_save_to_sqlite: 0,      # Enable saving to SQLite
  run_save_to_mongodb: 0      # Enable saving to MongoDB
)

# Verify configuration settings
puts 'Current configuration settings:'
puts configurator.config
puts "\nAvailable Methods:"
puts VitluchkoApplication::Configurator.available_methods

# Initialize the AppConfigLoader with the path to the default config and additional config directory
config_loader = AppConfigLoader.new(
  'config/default_config.yaml', # path to default config
  'config/yaml_config'          # directory containing additional YAML files
)

# Load configurations
config = config_loader.config

# Verify loaded configuration data (Pretty-print the loaded config)
config_loader.pretty_print_config_data

# Check if the 'logging' config exists
if config['logging'].nil?
  puts "Error: 'logging' configuration is missing!"
  exit 1
end

# Set up logging using configuration from logging.yaml
logging_config = config['logging']
VitluchkoApplication::LoggerManager.initialize_logger(logging_config)

# Log that the application started
VitluchkoApplication::LoggerManager.log_processed_file('Application started successfully')

# Check if 'web_scraping' key exists and contains necessary values
web_scraping_config = config['web_parser']['web_scraping']
if web_scraping_config.nil? || web_scraping_config['start_page'].nil?
  VitluchkoApplication::LoggerManager.log_error("Error: 'web_scraping' or 'start_page' configuration is missing!")
  exit 1
end

# Initialize the SimpleWebsiteParser with configurations loaded from YAML
website_parser = VitluchkoApplication::SimpleWebsiteParser.new(config)

# Only run the website parser if it's enabled in the configuration
if configurator.config[:run_website_parser] == 1
  begin
    # Start the website parsing process
    website_parser.start_parse

    # Log completion of the website parsing process
    VitluchkoApplication::LoggerManager.log_processed_file('Website parsing completed successfully')

    # Example: After parsing, save the data (if enabled)
    cart = VitluchkoApplication::Cart.new
    website_parser.item_collection.each { |item| cart.add_item(item) }

    if configurator.config[:run_save_to_csv] == 1
      # Save item collection to CSV
      cart.save_to_csv('output/products')
      VitluchkoApplication::LoggerManager.log_processed_file('Products saved to CSV.')
    end

    if configurator.config[:run_save_to_json] == 1
      # Save item collection to JSON
      cart.save_to_json('output/products')
      VitluchkoApplication::LoggerManager.log_processed_file('Products saved to JSON.')
    end

    if configurator.config[:run_save_to_yaml] == 1
      # Save item collection to YAML
      cart.save_to_yml('output')
      VitluchkoApplication::LoggerManager.log_processed_file('Products saved to YAML.')
    end
  rescue StandardError => e
    # Log errors that occur during the parsing or saving process
    VitluchkoApplication::LoggerManager.log_error("An error occurred during parsing or saving: #{e.message}")
  end
else
  puts 'Website parsing is disabled in the configuration.'
end

# Log the completion of all actions
VitluchkoApplication::LoggerManager.log_processed_file('All actions completed successfully.')
