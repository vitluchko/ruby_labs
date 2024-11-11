# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'logger'
require 'faker'

# Require the ItemContainer module
require_relative 'item_container'

# VitluchkoApplication module is the main module for handling the application's logic
# for web scraping and other related functionalities. It organizes and encapsulates
# methods and configuration specific to the Vitluchko application context.
module VitluchkoApplication
  CONFIG_PATH = File.join(File.dirname(__FILE__), '../config/default_config.yaml')

  # LoggerManager class is responsible for initializing and managing the application's logger
  class LoggerManager
    class << self
      attr_reader :application_logger, :error_logger

      # Initialize the logger with configuration
      def initialize_logger(config)
        directory = config.dig('logging', 'directory') || 'logs'
        level = config.dig('logging', 'level') || 'DEBUG'
        files = config.dig('logging', 'files') || {}

        # Set the log directory and ensure it exists
        FileUtils.mkdir_p(directory)

        # Create separate loggers for application and error logs
        @application_logger = Logger.new("#{directory}/#{files['application_log'] || 'application.log'}")
        @error_logger = Logger.new("#{directory}/#{files['error_log'] || 'error.log'}")

        # Set the logging level for both loggers
        @application_logger.level = Logger.const_get(level.upcase)
        @error_logger.level = Logger.const_get(level.upcase)
      end

      # Log information about the processed file
      def log_processed_file(message)
        application_logger.info("Processed File: #{message}")
      end

      # Log errors
      def log_error(message)
        error_logger.error("Error: #{message}")
      end

      # Log general actions
      def log_action(message)
        application_logger.info("Action: #{message}")
      end
    end
  end

  # Load default configuration from YAML
  def self.load_default_config
    YAML.load_file(CONFIG_PATH)['default']
  end

  # Create a directory for the specified category
  def self.create_category_directory(category)
    config = load_default_config
    yaml_dir = config['yaml_dir']
    products_dir = File.join(yaml_dir, 'products')

    # Create the main products directory if it doesn't exist
    FileUtils.mkdir_p(products_dir)

    # Create the category subdirectory
    category_dir = File.join(products_dir, category.downcase)
    FileUtils.mkdir_p(category_dir)

    LoggerManager.log_processed_file("Category directory created: #{category_dir}")

    category_dir
  end

  # Sanitize product name for use in the filename
  def self.sanitize_product_name(name)
    "#{name.downcase.gsub(/\s+/, '_').gsub(/[^\w_]/, '')}.yaml"
  end

  # Create a YAML file for a specific product
  def self.create_product_file(category, product)
    category_dir = create_category_directory(category)
    # Sanitize the product name for the filename
    product_filename = sanitize_product_name(product[:name])

    # Construct the full path for the product file
    product_file_path = File.join(category_dir, product_filename)

    # Data structure for the YAML file
    product_data = {
      'name' => product[:name],
      'price' => product[:price],
      'description' => product[:description],
      'media' => product[:media]
    }

    # Write the product data to a YAML file
    File.write(product_file_path, product_data.to_yaml)

    LoggerManager.log_processed_file("Created product file: #{product_file_path}")

    puts "Created product file: #{product_file_path}"
  rescue StandardError => e
    LoggerManager.log_error("Failed to create product file: #{e.message}")
    raise
  end

  # Item class to represent a product or unit in the system
  class Item
    include Comparable

    MAX_NAME_LENGTH = 25
    MAX_CATEGORY_LENGTH = 10
    MAX_DESCRIPTION_LENGTH = 18

    attr_accessor :name, :price, :description, :category, :image_path

    # Constructor to initialize the item with attributes and optional block customization
    def initialize(attributes = {}, &)
      # Set default values if no attributes are provided
      @name = attributes.fetch(:name, 'Unknown Item')
      @price = attributes.fetch(:price, 0.0)
      @description = attributes.fetch(:description, 'No description provided')
      @category = attributes.fetch(:category, 'Uncategorized')
      @image_path = attributes.fetch(:image_path, '/path/to/default_image.jpg')

      # Apply block customization if provided
      instance_eval(&) if block_given?

      # Log initialization details using LoggerManager
      LoggerManager.log_processed_file("Item initialized: #{@name}, Category: #{@category}, Price: #{@price}")
    end

    # Method to represent the object as a string
    def to_s
      "#{@name} (#{@category}) - Price: #{@price}, Description: #{@description}, Image: #{@image_path}"
    end

    # Alias info to to_s
    alias info to_s

    # Method to convert the object to a hash (using dynamic attributes)
    def to_h
      # Using instance_variables to get all instance variables dynamically
      instance_variables.each_with_object({}) do |var, hash|
        hash[var.to_s.delete('@').to_sym] = instance_variable_get(var)
      end
    end

    # Method to represent the object in a more inspect-friendly way
    def inspect
      "#<#{self.class.name} #{@name} | #{@category} | #{@price} | #{@description} | #{@image_path}>"
    end

    # Update method to allow modification of attributes through a block
    def update
      yield self if block_given?
    end

    # Class method to generate fake data for an Item
    def self.generate_fake
      name = Faker::Commerce.product_name[0...MAX_NAME_LENGTH]
      category = Faker::Commerce.department[0...MAX_CATEGORY_LENGTH]
      description = Faker::Lorem.sentence(word_count: 15)[0...MAX_DESCRIPTION_LENGTH]
      image_path = Faker::Internet.url(host: 'example.com', path: '/images/product.jpg')

      new(
        name: name,
        price: Faker::Commerce.price(range: 10..1000),
        description: description,
        category: category,
        image_path: image_path
      )
    end

    # Class method to generate multiple fake items and return as an array
    def self.generate_multiple_fake(count = 5)
      Array.new(count) { generate_fake }
    end

    # Class method to print generated items in a table-like format
    def self.print_fake_items_table(count = 5)
      items = generate_multiple_fake(count)
      # Print table header
      puts '------------------------------------------------------------------------'
      puts '| Name                      | Category   | Price  | Description         |'
      puts '------------------------------------------------------------------------'
      # Print each item in a row
      items.each do |item|
        puts "| #{item.name.ljust(25)} | #{item.category.ljust(10)} | #{format('%.2f', item.price)} | #{item.description.ljust(18)} |"
      end
      puts '------------------------------------------------------------------------'
    end
  end

  # Class to represent the shopping cart or collection of items
  class Cart
    include ItemContainer

    attr_accessor :items

    # Constructor to initialize the items array
    def initialize
      @items = []
      LoggerManager.log_action('New Cart initialized.')
    end

    # Method to add an item to the cart
    def add_item(item)
      @items << item
      LoggerManager.log_action("Item added: #{item.name}, Price: #{item.price}")
    end

    # Helper method to check if the cart is empty
    def check_empty_cart
      if @items.empty?
        LoggerManager.log_error('No items to save. The cart is empty.')
        puts 'Error: The cart is empty.'
        return true
      end
      false
    end

    # Helper method to create the directory for the given category
    def create_category_directory(output_directory, category)
      category_dir = File.join(output_directory, category)
      FileUtils.mkdir_p(category_dir)
      category_dir
    end

    # Helper method to sanitize the file name
    def sanitize_filename(name)
      name.gsub(/[^\w\s_-]/, '').gsub(/\s+/, '_').downcase
    end

    # Helper method to save product data to a text file
    def save_product_to_text_file(item, category_dir)
      filename = File.join(category_dir, "#{sanitize_filename(item.name)}.txt")
      File.open(filename, 'w') do |file|
        file.puts "Name: #{item.name}"
        file.puts "Price: $#{item.price}"
        file.puts "Category: #{item.category}"
        file.puts "Description: #{item.description}"
      end
      LoggerManager.log_action("Product saved to file: #{filename}")
    end

    # Method to save items to a plain text file
    def save_to_file(output_directory)
      return if check_empty_cart

      @items.each do |item|
        category_dir = create_category_directory(output_directory, item.category)
        save_product_to_text_file(item, category_dir)
      end
    end

    # Method to save items to a JSON file
    def save_to_json(output_directory)
      return if check_empty_cart

      @items.each do |item|
        category_dir = create_category_directory(output_directory, item.category)
        filename = File.join(category_dir, "#{sanitize_filename(item.name)}.json")

        File.write(filename, item.to_h.to_json)

        LoggerManager.log_action("Item saved to JSON file: #{filename}")
        puts "Item saved to JSON file: #{filename}"
      end
    end

    # Method to save items to a CSV file
    def save_to_csv(output_directory)
      return if check_empty_cart

      @items.each do |item|
        category_dir = create_category_directory(output_directory, item.category)
        filename = File.join(category_dir, "#{sanitize_filename(item.name)}.csv")

        CSV.open(filename, 'w', write_headers: true, headers: ['Name', 'Category', 'Price', 'Description', 'Image Path']) do |csv|
          csv << [item.name, item.category, item.price, item.description, item.image_path]
        end

        LoggerManager.log_action("Item saved to CSV file: #{filename}")
        puts "Item saved to CSV file: #{filename}"
      end
    end

    # Method to save each item as a separate YAML file
    def save_to_yml(directory)
      return if check_empty_cart

      # Ensure the base directory exists
      FileUtils.mkdir_p(directory)

      # Create 'products' directory if it doesn't exist
      products_dir = "#{directory}/products"
      FileUtils.mkdir_p(products_dir)

      @items.each do |item|
        # Create category directory under 'products' if it doesn't already exist
        category_dir = "#{products_dir}/#{item.category}"
        FileUtils.mkdir_p(category_dir)

        # Generate file name based on item name, converting spaces to underscores and making it lowercase
        file_name = "#{category_dir}/#{sanitize_filename(item.name)}.yml"

        # Write the item data to a YAML file
        File.write(file_name, item.to_h.to_yaml)

        LoggerManager.log_action("Cart item saved to YAML: #{file_name}")
        puts "Cart item saved to YAML: #{file_name}"
      end
    end
  end

  # Configurator class is responsible for managing configuration settings
  # and allows users to override default configurations with custom values.
  class Configurator
    attr_accessor :config

    # Initialize the Configurator with default configuration settings.
    #
    # Default settings include:
    # - run_website_parser: 0
    # - run_save_to_csv: 0
    # - run_save_to_json: 0
    # - run_save_to_yaml: 0
    # - run_save_to_sqlite: 0
    # - run_save_to_mongodb: 0
    def initialize
      @config = {
        run_website_parser: 0,    # Enable or disable website parsing
        run_save_to_csv: 0,       # Enable or disable saving to CSV
        run_save_to_json: 0,      # Enable or disable saving to JSON
        run_save_to_yaml: 0,      # Enable or disable saving to YAML
        run_save_to_sqlite: 0,    # Enable or disable saving to SQLite
        run_save_to_mongodb: 0    # Enable or disable saving to MongoDB
      }
    end

    # Method to configure custom settings by overriding default values.
    #
    # @param overrides [Hash] A hash of configuration keys and their new values
    def configure(overrides)
      overrides.each do |key, value|
        if @config.key?(key)
          @config[key] = value
        else
          puts "Warning: Invalid config key: #{key}"
        end
      end
    end

    # Class method to get a list of available configuration keys.
    #
    # @return [Array<Symbol>] List of available configuration keys
    def self.available_methods
      # Use %i for an array of symbols to improve performance and readability
      %i[run_website_parser run_save_to_csv run_save_to_json run_save_to_yaml run_save_to_sqlite run_save_to_mongodb]
    end
  end
end
