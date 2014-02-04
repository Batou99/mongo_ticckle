require File.join(File.dirname(__FILE__), 'conector_ar')
require File.join(File.dirname(__FILE__), 'static_collection')
require File.join(File.dirname(__FILE__), 'category')
require File.join(File.dirname(__FILE__), 'type')

class Topic < ActiveRecord::Base

  has_many :videos, dependent: :destroy

  belongs_to :user

  #has_many :tracked_topics
  #has_many :watchers, :through => :tracked_topics, :source => :user


  #before_create :generate_permalink

  #def generate_permalink
    #self.permalink = discussion.to_s.parameterize.split("-").slice(0..4).join("-")
  #end

  def permalink
    discussion.to_s.parameterize.split("-").slice(0..4).join("-")
  end
  def similiar_topics(categories = [category])
    Topic.
      where(category_id: categories.map(&:id)).
      where('id <> ?', id).
      limit(8)
  end

  def name
    self.discussion ? self.discussion.truncate(30) : nil
  end

  def to_param
    "#{self.id}-#{self.name.to_s.parameterize}"
  end

  def category_name
    Category.find(category_id).name rescue :unknown
  end

  def type_name
    Type.find(type_id).name rescue :unknown
  end
end

