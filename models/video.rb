require File.join(File.dirname(__FILE__), 'conector_ar')
class Video < ActiveRecord::Base
  belongs_to :origin_opinion, :class_name => "Video", :foreign_key => :origin_opinion_id
  belongs_to :reply_to_opinion, :class_name => "Video", :foreign_key => :reply_to_opinion_id

  belongs_to :user
  belongs_to :topic
  #validates :topic_id, presence: true

  has_many :ticckles, dependent: :destroy
  #has_many :viewings, dependent: :destroy, as: :viewable
  belongs_to :reply_to_opinion, :class_name => "Video", :foreign_key => :reply_to_opinion_id


  #def ticckles_count
    #ticckles ? ticckles.select { |t| t.active==true }.count : 0 
  #end
  #
  def depth
    reply_to_opinion ? reply_to_opinion.depth+1 : 0
  end

  def get_position
    return self.position unless self.position.blank?
    if depth == 0
      self.position = "0"
    elsif depth == 1
      idx = topic.videos.select { |v| v.depth == 1 }.sort { |x,y| x.id <=> y.id }.index(self)
      self.position = "%03d" % idx.to_s
    else
      idx = topic.videos.select { |v| v.depth == depth }.sort { |x,y| x.id <=> y.id }.index(self)
      last = "%03d" % idx.to_s
      self.position = "#{reply_to_opinion.position}-#{last}"
    end
    self.save
    self.position
  end

end

class Opinion < Video; end
