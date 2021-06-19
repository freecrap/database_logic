

namespace :database_logic do
    
    namespace :events do
	desc "Create events"
	task :create => :environment do
	    Dir.glob( Rails.root.join("app/sql/events/*.sql") ).sort.each do |f|
		event_name = File.basename(f).split("_").drop(1).join("_").split(".").first
		p " + Creating #{event_name}..."
		ActiveRecord::Base.connection.execute( File.read( f ).gsub("[DB]", ActiveRecord::Base.connection_config[:database]) )
	    end
	end
	
	desc "Drop events"
	task :drop => :environment do
	    Dir.glob( Rails.root.join("app/sql/events/*.sql") ).sort.each do |f|
		event_name = File.basename(f).split("_").drop(1).join("_").split(".").first
		p " - Dropping #{event_name}..."
		ActiveRecord::Base.connection.execute "drop event if exists #{ event_name }"
	    end
	end
	
	desc "Recreate events (drop & create)"
	task :recreate => [:drop, :create] do
	    p "Done!"
	end
    end # procedures
end