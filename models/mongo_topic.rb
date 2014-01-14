require 'mongoid'
class MongoTopic
  include Mongoid::Document

  field :discussion
  field :points, type: Integer
  field :tags, type: Array
  field :views_count, type: Integer
  field :permalink

  embeds_many :videos, class_name: 'MongoVideo'

end
