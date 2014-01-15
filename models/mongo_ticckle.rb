require 'mongoid'
class MongoTicckle
  include Mongoid::Document
  include Mongoid::Timestamps

  field :active, type: Boolean

  belongs_to :user, class_name: 'MongoUser'
  embedded_in :video, class_name: 'MongoVideo', inverse_of: :ticckles

end
