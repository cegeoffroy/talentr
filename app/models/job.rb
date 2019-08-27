class Job < ApplicationRecord
  belongs_to :user
  has_many :applications
  has_many :opening_keywords

end
