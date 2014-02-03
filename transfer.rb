require 'rubygems'
require 'pry'

require './models/user'
require './models/video'
require './models/topic'
require './models/ticckle'
require './models/ar_notification'
require './models/static_collection'
require './models/category'
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
      ticckle_notifications: conf.ticckle_notifications,
      reply_notifications: conf.reply_notifications,
      digest_emails: conf.digest_emails,
      social_mode: conf.social_mode,
      join_notifications: conf.join_notifications,
      email_ticckle_notification: user.get_share_config('email_ticckle_notification'),
      email_weekly_notification: user.get_share_config('email_weekly_notification'),
      email_video_response_notification: user.get_share_config('email_video_response_notification'),
      email_debate_contribution_notification: user.get_share_config('email_debate_contribution_notification'),
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

  Topic.all.each do |topic|
    mt = MongoTopic.timeless.create(
      discussion: topic.discussion,
      points: topic.points,
      views_count: topic.views_count,
      permalink: topic.permalink,
      updated_at: topic.updated_at,
      created_at: topic.created_at,
      marked_as_featured_at: topic.marked_as_featured_at,
      tags: [topic.category_name],
      type_id: topic.type_id,
      old_id: topic.id,
      active: topic.active
    )

    mt.user = mappings[:users][topic.user_id]
    mt.save

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

    mn = Notification.create(created_at: notification.created_at)
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
    mn.set(:created_at, notification.created_at)
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

