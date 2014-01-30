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
  field :thumbnail_file_name
  field :old_id
  field :position

  belongs_to :user, class_name: 'MongoUser'
  embedded_in :topic, class_name: 'MongoTopic', inverse_of: :videos
  embeds_many :ticckles, class_name: 'MongoTicckle'

  def username
    _id
  end

  def self.find_by_guid(guid)
    MongoTopic.all.flat_map(&:videos).select { |v| video_ids.include? v.id }
  end

end
