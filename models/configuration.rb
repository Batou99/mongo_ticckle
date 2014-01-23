require File.join(File.dirname(__FILE__), 'conector_ar')
class Configuration < ActiveRecord::Base
  belongs_to :user
end

