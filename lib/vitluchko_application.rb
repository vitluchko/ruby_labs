# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'logger'

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
end
