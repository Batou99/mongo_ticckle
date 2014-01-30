class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :noticeable, polymorphic: true
  belongs_to :sender, class_name: 'MongoUser'
  belongs_to :user, class_name: 'MongoUser'
  belongs_to :topic, class_name: 'MongoTopic'
end