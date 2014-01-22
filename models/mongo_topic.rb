require 'mongoid'

class MongoTopic
  include Mongoid::Document
  include Mongoid::Timestamps

  field :discussion
  field :points, type: Integer
  field :tags, type: Array
  field :views_count, type: Integer
  field :permalink
  field :popularity
  field :marked_as_featured_at, type: Date
  field :image
  field :old_id

  before_save :update_popularity
  after_create :update_popularity

  embeds_many :videos, class_name: 'MongoVideo'

  def update_popularity
    days = (Time.now - updated_at || Time.now).to_i / 1.day
    self.popularity = days / (1.0 + points)
  end

  def s3_image
    "http://s3.amazonaws.com/#{AMAZON_S3_CONFIG.image_bucket}/#{videos.first.thumbnail_file_name}"
  end

  def cloudfront_image
    "http://#{AMAZON_S3_CONFIG.cloudfront_images}/#{videos.first.thumbnail_file_name}"
  end

  def as_json(opts)
    json = super(opts.merge!(except: [:popularity, :marked_as_featured_at]))
    json["ticckles_count"] = videos.first.ticckles.size rescue 0
    json["replies_count"] = videos.size-1
    json["featured"] = !!marked_as_featured_at
    json["username"] = videos.first.user.username
    json["category_name"] = tags.select { |t| !t.match(/^#/) }.first
    json["image"] = cloudfront_image
    json
  end

end
