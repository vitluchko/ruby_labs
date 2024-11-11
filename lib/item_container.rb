# frozen_string_literal: true

require_relative 'vitluchko_application'

# ItemContainer module to extend functionality of classes
module ItemContainer
  # Class methods
  module ClassMethods
    # Returns the class information (name and version)
    def class_info
      "#{name} - Version 1.0"
    end

    # Keeps track of the number of instances created
    def count_instances
      @instance_count ||= 0
      @instance_count += 1
    end

    # Method to generate test items and add them to the collection
    def generate_test_items(count = 5)
      items = []
      count.times do
        item = Object.const_get('VitluchkoApplication::Item').generate_fake
        items << item
        VitluchkoApplication::LoggerManager.log_action("Test item added: #{item.name}")
      end
      items
    end
  end

  # Instance methods
  module InstanceMethods
    # Adds an item to the collection
    def add_item(item)
      @items << item
    end

    # Removes an item from the collection
    def remove_item(index)
      if @items && @items[index]
        removed_item = @items.delete_at(index)
        VitluchkoApplication::LoggerManager.log_action("Removed item from cart: #{removed_item.name}")
      else
        VitluchkoApplication::LoggerManager.log_error("Failed to remove item at index #{index}: Item not found")
        puts "Error: Item not found at index #{index}"
      end
    end

    # Deletes all items in the collection
    def delete_items
      @items.clear
    end

    # Handle method missing to display all items in the collection
    def method_missing(method_name, *args, &)
      # Apply block customization if provided
      instance_eval(&) if block_given?

      if method_name == :show_all_items
        show_all_items
      else
        super
      end
    end

    # Define respond_to_missing? to return true for any method we want to handle dynamically
    def respond_to_missing?(method_name, include_private = false)
      method_name == :show_all_items || super
    end

    # Show all items in the collection
    def show_all_items
      puts '------------------------------------------------------------------------'
      puts '| Name                      | Category   | Price  | Description         |'
      puts '------------------------------------------------------------------------'
      @items.each do |item|
        puts "| #{item.name.ljust(15)} | #{item.category.ljust(10)} | #{format('%.2f', item.price)} | #{item.description.ljust(18)} |"
      end
      puts '------------------------------------------------------------------------'
    end

    # Each method to be used with Enumerable
    def each(&)
      @items.each(&)
    end
  end

  # Callback method when module is included in a class
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end
end
