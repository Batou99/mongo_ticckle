require 'mongoid'
class MongoUser
  include Mongoid::Document

  field :email
  embeds_many :videos, class_name: 'MongoVideo'

  def username
    _id
  end

end
