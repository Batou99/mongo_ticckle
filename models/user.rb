require File.join(File.dirname(__FILE__), 'conector_ar')
require File.join(File.dirname(__FILE__), 'configuration')
require File.join(File.dirname(__FILE__), 'share_config')
require File.join(File.dirname(__FILE__), 'authentication')
require File.join(File.dirname(__FILE__), 'device')

class User < ActiveRecord::Base
  # FIXME: Move to yml file
  ONLINE_PRESENCE_TIMEOUT = 6.hours
  CONFIG_MAPPING = {
    email_ticckle_notification: :ticckle_notifications,
    email_video_response_notification: :reply_notifications,
    email_weekly_notification: :digest_emails,
    email_debate_contribution_notification: :join_notifications
  }

  has_many :videos
  has_many :topics, through: :videos
  #has_many :ticckles, dependent: :destroy
  #has_many :devices
  has_many :share_configs
  has_many :authentications
  has_one :configuration, foreign_key: 'person_id', primary_key: 'id'
  has_many :devices

  #has_many :tracked_topics
  #has_many :watches, :through => :tracked_topics, :source => :topic


  def as_json(*args)
    super(:methods => [:image, :full_name, :presence], :except => [:created_at, :email])
  end

  def rank
    User.where("points > ?", self.points).count + 1
  end

  def presence
    (updated_at - ONLINE_PRESENCE_TIMEOUT.ago) > 0 ? "online" : "offline"
  end

  def get_share_config(key)
    out = share_configs.where(key: key).first.value rescue false
    out == "1" || out == "on"
  end

  # - name - name of configuration from Configuration (not share config)
  def get_config(name)
    share_config = share_configs.where(key: CONFIG_MAPPING.key(name)).first
    get_share_config  = -> { share_config.value if share_config }
    get_configuration = -> { configuration.public_send(name) if configuration }

    share_config_defined = !get_share_config.call.nil?
    configuration_defined = !get_configuration.call.nil?

    truthy_values = ["1", "on", true, nil]

    config = if share_config_defined && configuration_defined
      get_configuration
    elsif share_config_defined
      get_share_config
    elsif configuration_defined
      get_configuration
    else
      -> { nil }
    end

    truthy_values.include?(config.call)
  end
end
