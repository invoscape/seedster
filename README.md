Seedster
========

Seedster is a plugin to dump from and load data into the database. You can use seedster to do the following:

+ Dump the entire database
+ Dump a specific set of tables
+ Load the entire database
+ Load a specific set of tables  

Dependencies 
------------
+	ruby >= 1.8.7
+	rails >= 3.0

Installation
============
+	Copy the entire plugin into __vendor/plugins/__ folder or execute

		rails plugin install git://github.com/invoscape/seedster.git
+	Execute

		rails generate seedster settings
	this will create a folder called seedster under __db__ and a file datasets.yml in the __seedster__ folder
+	Add your datasets details in the datasets.yml file created

Usage
=====
Seedster exposes few rake commands to help you dump and load data to the database!

+	To dump the entire database into your __db/seedster__ folder
	
	rake db:seedster:dump[:all,"An optional comment"]
	This will create a folder named "all" under the "seedster" folder under which another folder named version_an_optional_comment_[current_date]_[current_time] within which all the yaml files
	corresponding to all the tables in the database will be created.
	
	OR just
	rake db:seedster:dump
	This will create a dump of the entire database without any comment
	
+	To dump a specific dataset

	rake db:seedster:dump[dataset_name,"An optional comment"]  
	This will create a folder named dataset_name under which another folder named version_an_optional_comment_[current_date]_[current_time] under which all the yaml files
	corresponding to all the tables in the dataset you mentioned in datasets.yaml will be created.
	
+	To load the entire database

	rake db:seedster:load[:all]
	The yaml files under the latest version of the "all" folder will be taken and the database will be loaded accordingly
	
	rake db:seedster:load[:all,1]
	This command will load the version 1 of the database under "all" folder
	
	OR just
	rake db:seedster:load
	This will load the latest version of the entire database under "all" folder
	
+	To load a specific dataset

	rake db:seedster:load[dataset_name]
	The yaml files under the latest version of the "[dataset_name]" folder will be taken and the database will be loaded accordingly
	
	rake db:seedster:load[dataset_name,1]
	This command will load the version 1 of the database under "[dataset_name]" folder
	
+	To use in production mode

	rake db:seedster:dump[dataset_name] RAILS_ENV=production
	
	rake db:seedster:load[dataset_name,version] RAILS_ENV=production	
		
__Home page__ - [invoscape.com/open_source#seedster](http://www.invoscape.com/open_source#seedster)

__Want to contribute ?__ - Drop in a mail to opensource(at)invoscape(dot)com

Please do report any issues you face - [issues](https://github.com/invoscape/seedster/issues)

Copyright &copy; [Invoscape Technologies Pvt. Ltd.](http://www.invoscape.com), released under the MIT license