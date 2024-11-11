# frozen_string_literal: true

# lib/app_config_loader.rb
# This file contains the AppConfigLoader class, which is responsible for loading application configurations from YAML files.

require 'yaml'
require 'erb'
require 'json'
require 'fileutils'
require 'csv'

# AppConfigLoader is responsible for loading and merging configuration data from YAML files and managing library dependencies.
class AppConfigLoader
  attr_reader :config_data, :loaded_libs

  # Initialize the loader with paths
  def initialize(default_config_path, additional_configs_dir)
    @default_config_path = default_config_path
    @additional_configs_dir = additional_configs_dir
    @config_data = {}
    @loaded_libs = Set.new # Using a Set to keep track of loaded libraries
  end

  # Main method to load and process configuration data
  def config
    load_libs
    load_default_config
    load_additional_configs
    yield(@config_data) if block_given?
    @config_data
  end

  # Pretty print the configuration data in JSON format
  def pretty_print_config_data
    puts JSON.pretty_generate(@config_data)
  end

  # Method to load system and local libraries
  def load_libs
    load_system_libs
    load_local_libs
  end

  private

  # Load the default configuration file
  def load_default_config
    if File.exist?(@default_config_path)
      erb_content = ERB.new(File.read(@default_config_path)).result
      @config_data = YAML.safe_load(erb_content, permitted_classes: [Date, Time])
      puts "Loaded default configuration from #{@default_config_path}"
    else
      puts "Default config file #{@default_config_path} does not exist."
    end
  end

  # Load all YAML configuration files from the specified directory
  def load_additional_configs
    return unless Dir.exist?(@additional_configs_dir)

    Dir.glob(File.join(@additional_configs_dir, '*.yaml')).each do |file_path|
      config_name = File.basename(file_path, '.yaml')
      yaml_data = YAML.safe_load_file(file_path, permitted_classes: [Date, Time])
      @config_data[config_name] = yaml_data
      puts "Loaded additional configuration from #{file_path}"
    end
  end

  # Load system libraries
  def load_system_libs
    system_libs = %w[date json yaml erb fileutils set]

    system_libs.each do |lib|
      next if @loaded_libs.include?(lib)

      require lib
      @loaded_libs.add(lib)
      puts "Loaded system library: #{lib}"
    end
  end

  # Load all Ruby files from the libs directory
  def load_local_libs
    libs_dir = File.expand_path('../libs', __dir__)
    return unless Dir.exist?(libs_dir)

    Dir.glob(File.join(libs_dir, '**', '*.rb')).each do |file|
      lib_name = File.basename(file, '.rb')

      next if @loaded_libs.include?(lib_name)

      require_relative file
      @loaded_libs.add(lib_name)
      puts "Loaded local library: #{lib_name} from #{file}"
    end
  end
end
