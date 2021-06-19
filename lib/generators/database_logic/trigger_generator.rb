require 'rails/generators'
module DatabaseLogic
  module Generators
    class TriggerGenerator < Rails::Generators::Base
	
	argument :name, type: :string
	argument :run_when, type: :string
	argument :sql_action, type: :string
	argument :table, type: :string
	
	# <%= name %> <%= @when %> <%= @sql_action %> on <%= @table %>
	
	def generate(asset_type = :trigger)
	    ensure_path_exists! asset_type
	    validate_file_name! asset_type
	    validate_asset_name! asset_type
	    
	    @when = run_when
	    validate_when!
	    
	    @sql_action = sql_action
	    validate_sql_action!
	    
	    @table = table
	    validate_table!
	    
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
        
        
        def validate_table!
    	    raise Error.new("Must specify a table to attach trigger to") if @table.empty?
    	    # TODO check if table really exists
        end
        
        def validate_sql_action!
    	    raise Error.new("Trigger must run either on insert, update, create or delete") if !["insert", "update", "create", "delete"].include?(@sql_action.downcase)
        end
        
        def validate_when!
    	    raise Error.new("Trigger must run either before or after") if !["before", "after"].include?(@run_when.downcase)
        end
        
        
        def validate_asset_name!( asset_type )
    	    raise Error.new("#{ asset_type.to_s.capitalize } named #{serialized_asset_name} already exists, please choose another name") if Dir.glob(Rails.root.join("app/sql/#{ asset_type.to_s.pluralize }/*_#{serialized_asset_name}.sql")).size > 0
        end

        
        def validate_file_name!( asset_type )
    	    raise Error.new("File #{file_name_with_timestamp} already exists") if File.exist?( file_name_with_path( asset_type.to_s.pluralize ) )
        end
    end
  end
end
