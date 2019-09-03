class Candidate < ApplicationRecord
  has_many :infos
  has_many :job_applications
  belongs_to :user

  def days_since_applied
    (Date.today.to_date - job_applications.first.date.to_date).to_i
  end

  def websites
    infos.where(meta_key: 'webistes')[0].meta_value[:meta_value]
  end
end
