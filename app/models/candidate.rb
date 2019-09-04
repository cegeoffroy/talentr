class Candidate < ApplicationRecord
  has_many :infos
  has_many :job_applications
  belongs_to :user

  def days_since_applied
    (Date.today.to_date - job_applications.first.date.to_date).to_i
  end

  def websites
    infos.where(meta_key: 'websites')[0].meta_value[:websites]
  end

  FILTERS = ['Full Text', 'Suitability score', 'Experience', 'Experience years',
             'Relevant Experience years', 'Education years', 'Skills']
  COMPARATORS = ['contains', 'exactly equals', '>', '<']
end
