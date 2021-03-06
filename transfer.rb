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
  name = "ticckle_development"
  host = "localhost"
  port = 27017
  # config.connect_to name
  config.sessions = {
    default: {
      database: name,
      hosts: ["#{host}:#{port}"]
    }
  }
end

class CategoryMapper
  include CategoryMapping
end

def prepare
  MongoUser.delete_all
  MongoTopic.delete_all
  MongoVideo.delete_all
  MongoTopic.delete_all
  MongoTicckle.delete_all
  Notification.delete_all

  mappings = {
    users: {},
    videos: {},
    topics: {},
    ticckles: {}
  }

  User.all.each do |user|
    conf = user.configuration || Configuration.new
    auth = user.authentications.last || Authentication.new
    devices = user.devices.pluck(:token)
    mu = MongoUser.create(
      username: user.username, 
      email: user.email,
      full_name: [user.first_name, user.last_name].join(" "),
      avatar_url: user.avatar_url,
      ticckle_notifications: user.get_config(:ticckle_notifications),
      reply_notifications: user.get_config(:reply_notifications),
      digest_emails: user.get_config(:digest_emails),
      social_mode: conf.social_mode,
      join_notifications: user.get_config(:join_notifications),
      provider: auth.provider,
      uid: auth.uid,
      token: auth.token,
      secret: auth.secret,
      devices: devices,
      old_id: user.id,
      created_at: user.created_at,
      notifications_seen_at: user.notifications_seen_at
    )

    mappings[:users][user.id] = mu
  end

  category_mapper = CategoryMapper.new

  Topic.all.each do |topic|
    if topic.category
      category_name = category_mapper.map_to_new_category(topic.category).name
    else
      category_name = :obscure
    end

    mt = MongoTopic.timeless.create(
      discussion: topic.discussion,
      points: topic.points,
      views_count: topic.views_count,
      permalink: topic.permalink,
      updated_at: topic.updated_at,
      created_at: topic.created_at,
      marked_as_featured_at: topic.marked_as_featured_at,
      tags: [category_name, "type:#{topic.type_name}"],
      old_id: topic.id,
      active: topic.active
    )

    mappings[:topics][topic.id] = mt
  end

  Video.all.each do |video|
    next unless video.topic && video.topic.discussion && video.user
    mv = MongoVideo.new(
      title: video.title,
      points: video.points,
      length: video.length,
      guid: video.guid,
      s3_key: video.s3_key,
      state: video.state,
      thumbnail_file_name: "videos/thumbnails/#{video.id}/original/#{video.thumbnail_file_name}",
      old_id: video.id,
      created_at: video.created_at,
      position: video.get_position
    )
    topic = MongoTopic.where(permalink: video.topic.permalink).first
    user = MongoUser.where(username: video.user.username).first
    mv.topic = topic
    mv.user = user
    mv.save

    user.video_ids =[] if !user.video_ids
    user.video_ids << mv._id
    user.save

    video.ticckles.each do |ticckle|
      next unless ticckle.user
      mu = MongoUser.where(username: ticckle.user.username).first
      mt = MongoTicckle.create(
        active: ticckle.active,
        user: mu,
        video: mv
      )

      mappings[:ticckles][ticckle.id] = mt
    end

    mappings[:videos][video.id] = mv
  end

  MongoTopic.each(&:save)

  ARNotification.find_each do |notification|
    next unless mappings[:users].key?(notification.user_id) && mappings[:users].key?(notification.sender_id) && mappings[:topics].key?(notification.topic_id)

    mn = Notification.new
    mn.user   = mappings[:users][notification.user_id]
    mn.sender = mappings[:users][notification.sender_id]
    mn.topic  = mappings[:topics][notification.topic_id]

    noticeable = notification.noticeable
    if noticeable.kind_of?(Ticckle)
      mn.noticeable = mappings[:ticckles][noticeable.id]
    elsif noticeable.kind_of?(Opinion) || noticeable.kind_of?(Video)
      mn.noticeable = mappings[:videos][noticeable.id]
    end

    mn.save
    mn.set(:_type, notification.type)
    mn.set(:created_at, noticeable.try(:created_at) || notification.created_at)
  end
end
prepare

def map_user(user_id)
  %Q{
    function() {
      if (this.videos == null || this.videos[0] == null) {
        return;
      }
      if (this.videos[0].user_id == "#{user_id}")
        emit(this.videos[0].user_id, this._id);
    }
  }
end
reduce = %Q{
  function(key,values) {
    return { topics: values};
  }
}
binding.pry

