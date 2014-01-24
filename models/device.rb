require File.join(File.dirname(__FILE__), 'conector_ar')
class Device < ActiveRecord::Base
  belongs_to :user
end
