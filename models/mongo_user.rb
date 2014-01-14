require 'mongoid'
class MongoUser
  include Mongoid::Document

  field :email
  field :video_ids, type: Array

  def videos
    # This returns an enumerator that breaks on last element (count does not work)
    #MongoTopic.all.map(&:videos).flatten.find(video_ids)
    MongoTopic.all.map(&:videos).flatten.select { |v| video_ids.include? v.id }
  end

end
