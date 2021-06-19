# lib/railtie.rb
require 'database_logic'
require 'rails'

module DatabaseLogic
  class Railtie < Rails::Railtie
    railtie_name :database_logic

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/*.rake").each { |f| load f }
    end
  end
end
