require 'rubygems'
require 'pry'

require './models/user'
require './models/video'
require './models/topic'
require './models/mongo_user'
require './models/mongo_video'
require './models/mongo_topic'

require 'mongoid'

Mongoid.configure do |config|
  name = "ticckle_development"
  host = "localhost"
  port = 27017
  config.connect_to name
end
#client = Riak::Client.new(nodes: [host: '10.0.2.15'])
#bucket = client.bucket("users")
#
MongoUser.delete_all
MongoTopic.delete_all
MongoVideo.delete_all

User.all.each do |user|
  MongoUser.create(username: user.username, email: user.email).save
end

Topic.all.each do |topic|
  MongoTopic.create(
    discussion: topic.discussion,
    points: topic.points,
    views_count: topic.views_count,
    permalink: topic.permalink
  )
end

Video.all.each do |video|
  mv = MongoVideo.new(
    title: video.title,
    points: video.points,
    length: video.length,
    guid: video.guid,
    s3_key: video.s3_key,
    state: video.state
  )
  if video.user
    user = MongoUser.where(username: video.user.username).first
    mv.user = user
    mv.save
    user.videos << mv
    user.save
  end

  if video.topic && video.topic.discussion
    topic = MongoTopic.where(permalink: video.topic.permalink).first
    mv.topic = topic
    mv.save
    topic.videos << mv
    topic.save
  end
end

binding.pry

