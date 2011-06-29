class SeedSter
    
    SeedSterPath = "db/seedster/"
    
    public
    def initialize
        data_sets_file_path = SeedSterPath + "datasets.yml"
        @data_sets = YAML::load(File.open(data_sets_file_path))  
    end
    
    public
    def dump(data_set, dump_comment)
        #--- Create directory for the seed set if it is not created earlier
        data_set_name = data_set.to_s.gsub(":","")
        data_set_directory_path = SeedSterPath + data_set_name
        if not File.directory?(data_set_directory_path)
            puts "Creating seed set folder - #{data_set_directory_path}"
            FileUtils.mkdir_p(data_set_directory_path)    
        end
        
        #--- Find out the previous dump folders
        previous_folders = []
        Dir.foreach(data_set_directory_path) do |folder_name|
            previous_folders.push folder_name[0..3].to_s.to_i
        end
        previous_folders.sort!
        
        #--- Coin the new folder name
        new_dump_folder_name = ""
        new_dump_folder_name = new_dump_folder_name + dump_comment.downcase.gsub(' ', '_') + "_" if dump_comment != ""
        new_dump_folder_name = new_dump_folder_name + Time.current.strftime(" %d %b %Y %I:%M %p").gsub(" 0", " ").strip.downcase.gsub(', ', ' ').gsub(':', ' ').gsub(' ', '_')
        if previous_folders.length < 1
            new_dump_folder_name = "0000_" + new_dump_folder_name
        else
            new_dump_folder_name = "#{(previous_folders.last + 1).to_s.rjust(4, '0')}_" + new_dump_folder_name  
        end
        
        #--- Coin the directory name for the new dump
        new_dump_directory_name = data_set_directory_path + "/#{new_dump_folder_name}"
        
        #--- Create the directory within the group for new dump
        puts "Creating dump folder - #{new_dump_directory_name}"
        FileUtils.mkdir_p(new_dump_directory_name)
        
        #--- Prepare the tables to be dumped
        if data_set_name == :all.to_s
            tables_to_be_dumped = ActiveRecord::Base.connection.tables
        else
            tables_to_be_dumped = @data_sets[data_set_name]
        end
        
        #--- Print the tables that are going to be dumped
        puts
        puts "Creating dump for the following tables..."
        tables_to_be_dumped.each do |table_name|
            puts table_name
        end
        puts
        
        sql = "SELECT * FROM %s"
        ActiveRecord::Base.establish_connection(:development)
        tables_to_be_dumped.each do |table_name|
            #--- Skip the dump if table name does not exist
            if not ActiveRecord::Base.connection.tables.include?(table_name)
                puts
                puts "ERROR: '#{table_name}' table does not exist. Skipping...."
                puts
                next
            end
            
            #--- Dump to yaml file in db/seed_data folder
            i = "000"
            File.open("#{new_dump_directory_name}/#{table_name}.yml", 'w') do |file|
                data = ActiveRecord::Base.connection.select_all(sql % table_name)
                file.write data.inject({}) { |hash, record|
                    hash["#{table_name}_#{i.succ!}"] = record
                    hash
                }.to_yaml
            end
        end
        
        puts "-----------------------------------------------------------------------"
        puts "Dump created successfully!!!"
        puts "-----------------------------------------------------------------------"
    end
    
    public
    def load(data_set, dump_version, is_load_to_be_appended = false)
        #--- Prepare the version number according to folder name
        dump_version = dump_version.to_s.rjust(4, '0') if dump_version != nil
        
        #--- Check if dump has been created for this seed set yet
        data_set_name = data_set.to_s.gsub(":","")
        data_set_directory_path = SeedSterPath + data_set_name
        puts "Opening seed set path - '#{data_set_directory_path}'"
        if not File.directory?(data_set_directory_path)
            raise "No dump exists for #{data_set_name}!"
            return
        end
        
        #--- Find dumps created earlier
        puts "Looking for dumps for seed set - #{data_set_name}..."
        dump_folder_serails = []
        dump_folder_names = []
        Dir.foreach(data_set_directory_path) do |entry|
            dump_folder_serails.push entry[0..3].to_s.to_i
            dump_folder_names.push entry
        end
        dump_folder_serails.sort!
        
        #--- Check if any dumps were created at all
        if dump_folder_names.length < 0
            raise "No dump exists for #{data_set_name}!"
            return    
        end
        
        #--- Find dump folder for the version
        dump_folder_name_for_version = ""
        dump_folder_names.each do |dump_folder_name|
            if (dump_version == nil and dump_folder_name.include?(dump_folder_serails.last.to_s)) or (dump_version != nil and dump_folder_name.include?(dump_version))
                dump_folder_name_for_version = dump_folder_name
            end
        end 
        if dump_folder_name_for_version == ""
            raise "No dump exists for #{data_set_name} for the required version - #{dump_version.to_s}!"
            return 
        end
        
        puts "Chosen #{dump_folder_name_for_version} as the dump for the required version..."
        
        #--- Coin the directory name for the latest dump folder
        dump_folder_path = data_set_directory_path + "/" + dump_folder_name_for_version
        
        #--- Prepare the tables that have been dumped
        tables_already_dumped = []
        Dir.foreach(dump_folder_path) do |entry|
            if entry != "." and entry != ".."
                tables_already_dumped.push(entry.gsub(".yml",""))
            end
        end
        
        #--- Prepare the tables to be dumped
        if data_set_name == :all.to_s
            tables_to_be_dumped = ActiveRecord::Base.connection.tables
        else
            tables_to_be_dumped = @data_sets[data_set_name]
        end
        
        #--- Compare the list of tables and throw appropriate message
        if tables_already_dumped.sort != tables_to_be_dumped.sort or !are_all_tables_active_record_tables(tables_already_dumped.sort)
            puts
            STDOUT.print "The tables in the data set you are requesting to load is not the same as the tables in the dump #{dump_folder_name_for_version}. Are you sure you still want to load this version? (y/n) "
            input = STDIN.gets.strip
            if input == 'y' or input == 'Y'
                load_tables(tables_already_dumped, dump_folder_path)
            else
                exit
            end
        else
            load_tables(tables_already_dumped, dump_folder_path)
        end
    end
    
    private
    def load_tables(tables_already_dumped, dump_folder_path)
        #--- Print the tables that are going to be dumped
        puts
        puts "Loading the dump for the following tables..."
        tables_already_dumped.each do |table_name|
            puts table_name
        end
        puts
        
        #--- Call the rake task for loading to the database
        ENV['FIXTURES_PATH'] = dump_folder_path
        Rake::Task["db:fixtures:load"].invoke  
        
        puts "-----------------------------------------------------------------------"
        puts "Dump loaded successfully!!!"
        puts "-----------------------------------------------------------------------"
    end
    
    private
    def are_all_tables_active_record_tables(tables_already_dumped)
        tables_already_dumped.each do |table_name|
            if not ActiveRecord::Base.connection.tables.include?(table_name)
                return false
            end
        end
        return true
    end
end