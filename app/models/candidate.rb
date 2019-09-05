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

  def skills
    infos.where(meta_key: 'skills')[0].meta_value
  end

  def languages
    infos.where(meta_key: 'languages')[0].meta_value[:languages]
  end

  def education
    infos.where(meta_key: 'education')[0].meta_value[:education]
  end

  def certificates
    infos.where(meta_key: 'certificates')[0].meta_value
  end

  def experiences
    infos.where(meta_key: 'experience')[0].meta_value[:items]
  end

  def phone_number
    infos.where(meta_key: 'phone_number')[0].meta_value
  end

  FILTERS = ['Full Text', 'Suitability score', 'Experience years',
             'Similar Role Experience years', 'Education years', 'Skills', 'Certifications', 'Accept', 'Reject', 'Pending']
  COMPARATORS = ['contains', 'exactly equals', '>', '<']
end
