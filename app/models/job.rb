class Job < ApplicationRecord
  belongs_to :user
  has_many :applications
  has_many :job_keywords
  has_many :candidates, through: :applications
end
