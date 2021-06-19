

namespace :database_logic do
    # remove all SQL?
    desc "Create all stores SQL"
    task :create => :environment do
	["events", "triggers", "procedures", "views", "functions"].reverse.each do |t|
	    Rake::Task["database_logic:#{t}:create"].invoke
	end
    end
    
    
    desc "Drop all stored SQL"
    task :drop => :environment do
	["events", "triggers", "procedures", "views", "functions"].each do |t|
	    Rake::Task["database_logic:#{t}:drop"].invoke
	end
    end
    
    
    desc "Drop and re-create all stored SQL"
    task :recreate => :environment do
	Rake::Task["database_logic:drop"].invoke
	Rake::Task["database_logic:create"].invoke
    end
end


# on drop, drop SQL too
#Rake::Task["db:drop"].enhance ["database_logic:drop"]


# on migration, re-run all SQL
#Rake::Task["db:migrate"].enhance do
#    Rake::Task["database_logic:recreate"].execute
#end