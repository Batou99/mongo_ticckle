
require 'rubygems'
require 'pry'

require './models/topic'
require './models/ar_notification'
require './models/mongo_topic'

require 'mongoid'

Mongoid.configure do |config|
  name = "ticckle_production"
  host = "localhost"
  port = 27017
  # config.connect_to name
  config.sessions = {
    default: {
      database: name,
      hosts: ["#{host}:#{port}"]
    }
  }
  MongoTopic.each { |mt|
    t = Topic.find_by_id(mt.old_id)
    next unless t
    mt.title = t.description if mt.title == nil && t.description != nil
    mt.save
  }
end


