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

end
