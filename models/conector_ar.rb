require 'rubygems'
require 'active_record'  

# ActiveRecord::Base.logger = Logger.new(STDOUT)
# ActiveRecord::Base.logger.level = Logger::DEBUG

ActiveRecord::Base.establish_connection(  
:adapter => "mysql2",  
:host => "dev",  
:database => "ticckle_production", 
:username => "root", 
:password => "maverick",
:encoding => "utf8"
)
