class ARNotification < ActiveRecord::Base
  self.table_name = :notifications

  belongs_to :noticeable, polymorphic: true
end

class TicckleNotification < ARNotification; end
class ReplyNotification < ARNotification; end
class TopicJoinNotification < ARNotification; end