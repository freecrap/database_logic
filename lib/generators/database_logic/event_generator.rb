require 'rails/generators'
module DatabaseLogic
  module Generators
    class EventGenerator < Rails::Generators::Base
	
	argument :name, type: :string
	argument :frequency, type: :string
	argument :time_unit, type: :string
	
	def generate(asset_type = :event)
	    ensure_path_exists! asset_type
	    validate_file_name! asset_type
	    validate_asset_name! asset_type
	    
	    @frequency = frequency
	    validate_frequency!
	    
	    @time_unit = time_unit
	    validate_time_unit!
	    create_asset! asset_type
	end

	
      private
      
        def create_asset!(asset_type)
	    @name = serialized_asset_name
    	    create_file file_name_with_path(asset_type.to_s.pluralize), ERB.new( File.read( "#{ File.dirname(File.realpath(__FILE__)) }/templates/#{asset_type}.erb.sqlt"  )  ).result(binding)
        end
      
      
        def ensure_path_exists!(asset_dir)
    	    FileUtils.mkdir_p Rails.root.join("app/sql/#{ asset_dir.to_s.pluralize }")
        end
        
        
        def timestamp
    	    Time.now.strftime("%Y%M%d%H%M%S")
        end
        
        
        def file_name_with_timestamp
    	    "#{ timestamp }_#{ serialized_asset_name }"
        end
        
        
        def file_name_with_path( dir )
    	    Rails.root.join "app/sql/#{ dir }/#{ file_name_with_timestamp }.sql"
        end
        
        
        def asset_name
    	    name
    	end
    	
        
        def serialized_asset_name
    	    asset_name.parameterize.underscore
        end
        
        
        def validate_frequency!
    	    raise Error.new("Event frequency must be between 1 and 65535") if @frequency.to_i <= 0 || @frequency.to_i > 65535
        end
        
        
        def validate_time_unit!
    	    raise Error.new("A scheduled event must execute every second|minute|hour|day|week|month") if !["second", "minute", "hour", "day", "week", "month"].include?(@time_unit.to_s)
        end
        
        
        def validate_asset_name!( asset_type )
    	    raise Error.new("#{ asset_type.to_s.capitalize } named #{serialized_asset_name} already exists, please choose another name") if Dir.glob( Rails.root.join( "app/sql/#{ asset_type.to_s.pluralize }/*_#{serialized_asset_name}.sql") ).size > 0
        end

        
        def validate_file_name!( asset_type )
    	    raise Error.new("File #{file_name_with_timestamp} already exists") if File.exist?( file_name_with_path( asset_type.to_s.pluralize ) )
        end
    end
  end
end
