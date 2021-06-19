

namespace :database_logic do
    
    namespace :views do
	desc "Create views"
	task :create => :environment do
	p "Creating views"
	    Dir.glob( Rails.root.join("app/sql/views/*.sql") ).sort.each do |f|
		view_name = File.basename(f).split("_").drop(1).join("_").split(".").first
		p " + Creating #{view_name}..."
		ActiveRecord::Base.connection.execute( File.read( f ).gsub("[DB]", ActiveRecord::Base.connection_config[:database]) )
	    end
	end
	
	desc "Drop views"
	task :drop => :environment do
	    Dir.glob( Rails.root.join("app/sql/views/*.sql") ).sort.each do |f|
		view_name = File.basename(f).split("_").drop(1).join("_").split(".").first
		p " - Dropping #{view_name}..."
		ActiveRecord::Base.connection.execute "drop view if exists #{ view_name }"
	    end
	end
	
	desc "Recreate views (drop & create)"
	task :recreate => [:drop, :create] do
	    p "Done!"
	end
    end # views
    
    
end