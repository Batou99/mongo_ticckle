
require 'rubygems'
require 'pry'

require './models/user'
require './models/video'
require './models/topic'
require './models/ticckle'
require './models/ar_notification'
require './models/static_collection'
require './models/category'
require './models/category_mapping'
require './models/mongo_user'
require './models/mongo_video'
require './models/mongo_topic'
require './models/mongo_ticckle'
require './models/mongo_notification'

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


