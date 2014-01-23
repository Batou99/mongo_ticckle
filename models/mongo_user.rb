require 'mongoid'
class MongoUser
  include Mongoid::Document

  field :email
  field :video_ids, type: Array

  # Configurations
  field :ticckle_notifications, type: Boolean, default: false
  field :reply_notifications, type: Boolean, default: false
  field :digest_emails, type: Boolean, default: false
  field :social_mode, type: Boolean, default: false
  field :join_notifications, type: Boolean, default: false

  # Share Configs
  field :email_ticckle_notification, type: Boolean, default: true
  field :email_weekly_notification, type: Boolean, default: true
  field :email_video_response_notification, type: Boolean, default: true

  # Authentication
  field :provider
  field :uid
  field :token
  field :secret

  def videos
    # This returns an enumerator that breaks on last element (count does not work)
    #MongoTopic.all.map(&:videos).flatten.find(video_ids)
    MongoTopic.all.flat_map(&:videos).select { |v| video_ids.include? v.id }
  end

end
