require 'mongoid'
class MongoTopic
  include Mongoid::Document
  include Mongoid::Timestamps

  field :discussion
  field :points, type: Integer
  field :tags, type: Array
  field :views_count, type: Integer
  field :permalink
  field :popularity

  before_save :update_popularity
  after_create :update_popularity

  embeds_many :videos, class_name: 'MongoVideo'

  def update_popularity
    days = (Time.now - updated_at || Time.now).to_i / 1.day
    self.popularity = days / (1.0 + points)
  end

end
