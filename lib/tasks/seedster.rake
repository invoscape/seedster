require File.join(File.dirname(__FILE__), "..", "seedster")

namespace :db do
    namespace :seedster do
        task :dump, [:data_set, :dump_comment] => :environment do |t, args|
            #--- Assign default value to argument if not supplied
            args.with_defaults(:data_set => "all",:dump_comment => "")
            
            SeedSter.new.dump(args.data_set.to_sym, args.dump_comment)
        end
        
        task :load, [:data_set, :dump_version] => :environment do |t, args|
            #--- Assign default value to argument if not supplied
            args.with_defaults(:data_set => "all")
            
            SeedSter.new.load(args.data_set.to_sym, args.dump_version)
        end
    end
end


#---------- Methods ----------
#----------/Methods ----------