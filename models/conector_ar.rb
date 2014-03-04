require 'rubygems'
require 'active_record'  

# ActiveRecord::Base.logger = Logger.new(STDOUT)
# ActiveRecord::Base.logger.level = Logger::DEBUG

ActiveRecord::Base.establish_connection(  
:adapter => "mysql2",  
:host => "ticckledbinstance.cmd1tckkpcjq.us-east-1.rds.amazonaws.com",  
:database => "ticckle_production", 
:username => "ticckle", 
:password => "databasehub666",
:encoding => "utf8"
)
