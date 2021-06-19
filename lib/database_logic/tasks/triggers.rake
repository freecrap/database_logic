

namespace :database_logic do
    
    namespace :triggers do
	desc "Create triggers"
	task :create => :environment do
	    Dir.glob( Rails.root.join("app/sql/triggers/*.sql") ).sort.each do |f|
		trigger_name = File.basename(f).split("_").drop(1).join("_").split(".").first
		p " + Creating #{trigger_name}..."
		ActiveRecord::Base.connection.execute( File.read( f ).gsub("[DB]", ActiveRecord::Base.connection_config[:database]) )
	    end
	end
	
	desc "Drop triggers"
	task :drop => :environment do
	    Dir.glob( Rails.root.join("app/sql/triggers/*.sql") ).sort.each do |f|
		trigger_name = File.basename(f).split("_").drop(1).join("_").split(".").first
		p " - Dropping #{trigger_name}..."
		ActiveRecord::Base.connection.execute "drop trigger if exists #{ trigger_name }"
	    end
	end
	
	desc "Recreate triggers (drop & create)"
	task :recreate => [:drop, :create] do
	    p "Done!"
	end
    end # triggers
    
end