class Job < ApplicationRecord
  belongs_to :user
  has_many :job_applications
  has_many :job_keywords
  has_many :keywords, through: :job_keywords
  has_many :candidates, through: :job_applications

  validates :title, presence: true
  validates :due_date, presence: true
end
