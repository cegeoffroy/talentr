class Job < ApplicationRecord
  belongs_to :user
  has_many :job_applications
  has_many :job_keywords
  has_many :candidates, through: :job_applications
end
