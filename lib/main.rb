# frozen_string_literal: true

# Import necessary files
require_relative 'app_config_loader'
require_relative 'vitluchko_application'

# Initialize the AppConfigLoader with the path to the default config and additional config directory
config_loader = AppConfigLoader.new(
  'config/default_config.yaml', # path to default config
  'config/yaml_config' # directory containing additional YAML files
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
logging_config = config['logging'] # assuming 'logging' configuration exists
VitluchkoApplication::LoggerManager.initialize_logger(logging_config)

# Log that the application started
VitluchkoApplication::LoggerManager.log_processed_file('Application started successfully')

# Sample product data for creating a product file
product = {
  name: 'Nutrilite™ Vitamin D, 60 tabs',
  price: 25.99,
  description: 'Nutrilite™ Vitamin D supplement for healthy bones.',
  media: %w[image_url_1 image_url_2]
}

category = 'Vitamins'

# Create the product file
begin
  VitluchkoApplication.create_product_file(category, product)
  VitluchkoApplication::LoggerManager.log_processed_file("Product file created successfully: #{product[:name]}")
rescue StandardError => e
  VitluchkoApplication::LoggerManager.log_error("Failed to create product file: #{e.message}")
end

# Test logging an error to the error log
VitluchkoApplication::LoggerManager.log_error('Test error log')

# Generate 10 fake items and display them in a table format using the new method
puts "\nGenerated fake items:"
items = 10.times.map { VitluchkoApplication::Item.generate_fake }

# Call the print_fake_items_table method to display the generated items
VitluchkoApplication::Item.print_fake_items_table(items)

# Demonstrating the use of update method to change attributes of the first item
first_item = items.first
first_item.update do |item|
  item.price = 29.99
  item.description = 'Updated description with new price!'
end
puts "\nUpdated first item:"
puts first_item.info

# Convert all items to a hash and print the details
puts "\nItems in hash format:"
items.each do |item|
  puts item.to_h
end

# Use the inspect method for detailed inspection of all items
puts "\nInspecting all items:"
items.each do |item|
  puts item.inspect
end
