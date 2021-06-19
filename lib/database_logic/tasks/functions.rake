

namespace :database_logic do
    
    namespace :functions do
	desc "Create stored functions"
	task :create => :environment do
	    Dir.glob( Rails.root.join("app/sql/functions/*.sql") ).sort.each do |f|
		function_name = File.basename(f).split("_").drop(1).join("_").split(".").first
		p " + Creating #{function_name}..."
		ActiveRecord::Base.connection.execute( File.read( f ).gsub("[DB]", ActiveRecord::Base.connection_config[:database] ) )
	    end
	end
	
	desc "Drop stored functions"
	task :drop => :environment do
	    Dir.glob( Rails.root.join("app/sql/functions/*.sql") ).sort.each do |f|
		function_name = File.basename(f).split("_").drop(1).join("_").split(".").first
		p " - Dropping #{function_name}..."
		ActiveRecord::Base.connection.execute "drop function if exists #{ function_name }"
	    end
	end
	
	desc "Recreate stored functions (drop & create)"
	task :recreate => [:drop, :create] do
	    p "Done!"
	end
    end # functions
    
end