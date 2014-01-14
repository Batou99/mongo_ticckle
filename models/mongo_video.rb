require 'mongoid'
class MongoVideo
  include Mongoid::Document

  field :title
  field :tags, type: Array
  field :points, type: Integer
  field :length, type: Float
  field :guid
  field :s3_key
  field :state

  belongs_to :user, class_name: 'MongoUser'
  embedded_in :topic, class_name: 'MongoTopic', inverse_of: :videos

  def username
    _id
  end

end
