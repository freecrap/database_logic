

namespace :database_logic do
    
    namespace :procedures do
	desc "Create stored procedures"
	task :create => :environment do
	    Dir.glob( Rails.root.join("app/sql/procedures/*.sql") ).sort.each do |f|
		procedure_name = File.basename(f).split("_").drop(1).join("_").split(".").first
		p " + Creating #{procedure_name}..."
		ActiveRecord::Base.connection.execute( File.read( f ).gsub("[DB]", ActiveRecord::Base.connection_config[:database] ) )
	    end
	end
	
	desc "Drop stored procedures"
	task :drop => :environment do
	    Dir.glob( Rails.root.join("app/sql/procedures/*.sql") ).sort.each do |f|
		procedure_name = File.basename(f).split("_").drop(1).join("_").split(".").first
		p " - Dropping #{procedure_name}..."
		ActiveRecord::Base.connection.execute "drop procedure if exists #{ procedure_name }"
	    end
	end
	
	desc "Recreate stored procedures (drop & create)"
	task :recreate => [:drop, :create] do
	    p "Done!"
	end
    end # procedures
    
    
end