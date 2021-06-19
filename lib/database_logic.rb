# frozen_string_literal: true

require_relative "database_logic/version"

module DatabaseLogic
  class Error < StandardError; end

  # Your code goes here...
  require 'database_logic/railtie' if defined?(Rails)
end
