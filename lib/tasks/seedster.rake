require File.join(File.dirname(__FILE__), "..", "seedster")

namespace :db do
    namespace :seedster do
        task :dump, [:data_set, :dump_comment] => :environment do |t, args|
            if args.data_set.nil?
                puts
                puts "ERROR: Provide the data set name that you would like to dump with an optional comment."
                puts "Eg. rake db:seedster:dump[data_set_name,Test seed]"
                puts "To dump the entire set of tables use rake db:seedster:dump[:all,Test seed for all tables]"
                puts
                exit
            end
            
            #--- Assign default value to argument if not supplied
            args.with_defaults(:dump_comment => "")
            SeedSter.new.dump(args.data_set.to_sym, args.dump_comment)
        end
        
        task :load, [:data_set, :dump_version] => :environment do |t, args|
            if args.data_set.nil?
                puts
                puts "ERROR: Provide the data set name that you would like to load with the version you would like to load."
                puts "Note that if you do not provide a version the latest version will be taken into account."
                puts "Eg. rake db:seedster:load[data_set_name,1]"
                puts "To load the entire set of tables use rake db:seedster:load[:all,1]"
                puts
                exit
            end
            SeedSter.new.load(args.data_set.to_sym, args.dump_version)
        end
    end
end


#---------- Methods ----------
#----------/Methods ----------