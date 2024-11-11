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
  run_save_to_sqlite: 1,      # Enable saving to SQLite
  run_save_to_mongodb: 1      # Enable saving to MongoDB
)

# Verify configuration settings
puts 'Current configuration settings:'
puts configurator.config
puts "\nAvailable Methods:"
puts VitluchkoApplication::Configurator.available_methods

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
logging_config = config['logging']
VitluchkoApplication::LoggerManager.initialize_logger(logging_config)

# Log that the application started
VitluchkoApplication::LoggerManager.log_processed_file('Application started successfully')

# Sample product data for creating a product file
product1 = {
  name: 'Nutrilite™ Vitamin D, 60 tabs',
  price: 25.99,
  description: 'Nutrilite™ Vitamin D supplement for healthy bones.',
  media: %w[image_url_1 image_url_2]
}

product2 = {
  name: 'Omega-3 Fish Oil, 100 caps',
  price: 19.99,
  description: 'High-quality omega-3 fish oil supplement for heart health.',
  media: %w[image_url_3 image_url_4]
}

product3 = {
  name: 'Nutrilite™ Vitamin C, 100 tabs',
  price: 18.50,
  description: 'Vitamin C for boosting immunity.',
  media: %w[image_url_5 image_url_6]
}

product4 = {
  name: 'Probiotic Supplement, 30 caps',
  price: 29.99,
  description: 'High-quality probiotic supplement for gut health.',
  media: %w[image_url_7 image_url_8]
}

product5 = {
  name: 'Multivitamin, 120 tabs',
  price: 49.99,
  description: 'Comprehensive multivitamin supplement for overall health.',
  media: %w[image_url_9 image_url_10]
}

category = 'Vitamins'

# Initialize the Cart (Shopping cart)
cart = VitluchkoApplication::Cart.new

# Add items to the cart (use the sample product data)
products = [
  product1, product2, product3, product4, product5
]

# Create the product item
products.each do |item_data|
  item = VitluchkoApplication::Item.new(
    name: item_data[:name],
    price: item_data[:price],
    description: item_data[:description],
    category: item_data[:category] || category, # Default category if not provided
    image_path: item_data[:media].first
  )

  cart.add_item(item)
  VitluchkoApplication::LoggerManager.log_action("Item added to cart: #{item.name}")
end

# Display all items in the cart
puts "\nCart Items Before Deletion:"
cart.show_all_items

# Example: Deleting an item from the cart (by index 0)
puts "\nDeleting the first item from the cart..."
cart.remove_item(0)

# Display cart items after deletion of one item
puts "\nCart Items After Deleting One Item:"
cart.show_all_items

# Example: Saving remaining cart items to files based on the configurator settings
begin
  # Check if saving to CSV is enabled
  cart.save_to_csv('config/yaml_config/products') if configurator.config[:run_save_to_csv] == 1

  # Check if saving to JSON is enabled
  cart.save_to_json('config/yaml_config/products') if configurator.config[:run_save_to_json] == 1

  # Check if saving to YAML is enabled, and only if enabled (set to 1)
  if configurator.config[:run_save_to_yaml] == 1
    cart.save_to_yml('config/yaml_config')
  else
    puts 'YAML saving is disabled by the configuration.'
  end

  # Log success
  VitluchkoApplication::LoggerManager.log_processed_file('Cart items saved successfully.')
rescue StandardError => e
  # Log any errors that occur during saving
  VitluchkoApplication::LoggerManager.log_error("Error while saving cart items: #{e.message}")
end

# Show items in cart after saving
puts "\nCart Items Before Clearing:"
cart.show_all_items

# Clear the cart
puts "\nClearing the cart..."
cart.delete_items

# Show items in cart after clearing
puts "\nCart Items After Clearing:"
cart.show_all_items

# Log the completion of all actions
VitluchkoApplication::LoggerManager.log_processed_file('All cart actions completed successfully.')
