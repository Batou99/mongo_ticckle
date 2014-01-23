require 'rubygems'
require 'pry'

require './models/user'
require './models/video'
require './models/topic'
require './models/ticckle'
require './models/static_collection'
require './models/category'
require './models/mongo_user'
require './models/mongo_video'
require './models/mongo_topic'
require './models/mongo_ticckle'

require 'mongoid'

Mongoid.configure do |config|
  name = "ticckle_development"
  host = "localhost"
  port = 27017
  config.connect_to name
end

def prepare
  MongoUser.delete_all
  MongoTopic.delete_all
  MongoVideo.delete_all
  MongoTopic.delete_all

  User.all.each do |user|
    conf = user.configuration || Configuration.new
    auth = user.authentications.last || Authentication.new
    MongoUser.create(
      username: user.username, 
      email: user.email,
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
      secret: auth.secret
    )
    
  end

  Topic.all.each do |topic|
    MongoTopic.timeless.create(
      discussion: topic.discussion,
      points: topic.points,
      views_count: topic.views_count,
      permalink: topic.permalink,
      updated_at: topic.updated_at,
      created_at: topic.created_at,
      marked_as_featured_at: topic.marked_as_featured_at,
      tags: [topic.category_name],
      old_id: topic.id
    )
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
      depth: video.depth
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
      mu = MongoUser.where(username: ticckle.user.username).first
      MongoTicckle.create(
        active: ticckle.active,
        user: mu,
        video: mv
      )
    end

  end
end
prepare
#
#map = %Q{
  #function() {
    #if (this.videos == null || this.videos.first == null) {
      #return;
    #}
    #if (this.videos.first.user_id == '52de60b5d384a9d35c000014') {
      #emit(this.videos.first.user_id, this);
    #}
  #}
#}
#reduce = %Q{
  #function(k,v) {
    #return v;
  #}
#}
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

