class Ticckle < ActiveRecord::Base
  belongs_to :user
  has_one :video_user, through: :video, source: 'user'
  has_one :video_topic, through: :video, source: 'topic'
  has_many :tags, through: :video
  belongs_to :video
  validates :user_id, uniqueness: { scope:  [:video_id, :active] }, presence: true
  validate :ticckling_own_video

  scope :active, where(active: true)
  scope :recent, order('created_at DESC')

  after_save :update_video_score
  delegate :image, :topic_title, :points, :origin_opinion_id, :topic_id, :topic, to: :video

  def update_video_score
    self.video.calculate_points
    self.video.delay.update_scores
  end

  def unticckle
    self.update_attribute(:active, false)
  end

  def as_json(*args)
    super(:methods => [:topic_id, :image, :tags, :user_name, :video, :topic_title,
                       :video_user_id, :points, :origin_opinion_id ])
  end

  def video_user_id
    video_user.id
  end

  def image
     video.image
  end

  def ticckling_own_video
    errors.add(:user_id, 'invaild') if (self.user_id == self.video.user_id)
  end

  def user_name
    video_user.full_name
  end

  def noticable
    self.video
  end
end
