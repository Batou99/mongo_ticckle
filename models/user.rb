require File.join(File.dirname(__FILE__), 'conector_ar')

class User < ActiveRecord::Base
  # FIXME: Move to yml file
  ONLINE_PRESENCE_TIMEOUT = 6.hours

  has_many :videos
  has_many :topics, through: :videos
  #has_many :ticckles, dependent: :destroy
  #has_many :devices
  #has_many :share_configs

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
end
