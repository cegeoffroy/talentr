class Candidate < ApplicationRecord
  has_many :infos
  has_many :job_applications
  belongs_to :job

  def days_since_applied
    (Date.today.to_date - created_at.to_date).to_i
  end
end
