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

topic = Topic.first
videos = topic.videos
users = videos.map(&:user)
musers = {}

MongoTopic.create(
  discussion: topic.discussion,
  points: topic.points,
  views_count: topic.views_count,
  permalink: topic.permalink
)

users.each do |user|
  MongoUser.create(username: user.username, email: user.email)
end

videos.each do |video|
  mv = MongoVideo.new(
    title: video.title,
    points: video.points,
    length: video.length,
    guid: video.guid,
    s3_key: video.s3_key,
    state: video.state
  )
  mu = MongoUser.where(username: video.user.username).first
  #mt = MongoTopic.where(permalink: video.topic.permalink).first
  mt = MongoTopic.first
  mv.topic = mt
  mv.user = mu
  mv.save
  mu.video_ids = [] if !mu.video_ids
  mu.video_ids << mv._id
  mu.save
end

binding.pry


