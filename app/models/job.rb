class Job < ApplicationRecord
  belongs_to :user
  has_many :job_applications
  has_many :job_keywords
  has_many :keywords, through: :job_keywords
  has_many :candidates, through: :job_applications

  validates :title, presence: true
  validates :due_date, presence: true

  def self.search(job, fields)
    all_results = []
    candidates = job.candidates
    fields.each do |field|
      split_field = field.split("---")
      variable = split_field[0]
      comparator = split_field[1]
      value = split_field[2]
      case variable
      when "Full Text"
        if comparator == 'contains'
          infos = Info.where(candidate_id: candidates.ids, meta_key: 'full_text').search_by_meta_value(value)
        end
      when "Suitability Score"
        if comparator == ">"
          job_apps = JobApplication.where(candidate_id: c.ids).where("suitability > ?", value)
        elsif comparator == "<"
          job_apps = JobApplication.where(candidate_id: c.ids).where("suitability < ?", value)
        elsif comparator == "="
          job_apps = JobApplication.where(candidate_id: c.ids).where("suitability = ?", value)
        end
      when "Experience Years"
        infos = Info.where(candidate_id: candidates.ids, meta_key: 'experience')
        if comparator == ">"
          infos = infos.to_a.delete_if { |info| info.experience_duration < value }
        elsif comparator == "<"
          infos = infos.to_a.delete_if { |info| info.experience_duration > value }
        elsif comparator == "="
          infos = infos.to_a.delete_if { |info| info.experience_duration != value }
        end
      when "Similar Role Experience Years"
        infos = Info.where(candidate_id: candidates.ids, meta_key: 'experience')
        if comparator == ">"
          infos = infos.to_a.delete_if { |info| info.similar_role_experience_duration(job) < value }
        elsif comparator == "<"
          infos = infos.to_a.delete_if { |info| info.similar_role_experience_duration(job) > value }
        elsif comparator == "="
          infos = infos.to_a.delete_if { |info| info.similar_role_experience_duration(job) != value }
        end
      when "Education Years"
        infos = Info.where(candidate_id: candidates.ids, meta_key: 'education')
        if comparator == ">"
          infos = infos.to_a.delete_if { |info| info.education_duration < value }
        elsif comparator == "<"
          infos = infos.to_a.delete_if { |info| info.education_duration > value }
        elsif comparator == "="
          infos = infos.to_a.delete_if { |info| info.education_duration != value }
        end
      when "Skills"
        if comparator == 'contains'
          infos = Info.where(candidate_id: candidates.ids, meta_key: 'skills')
          infos = infos.to_a.delete_if { |info| info.word_in_meat_value_array? > value }
        end
      when "Certifications"
        if comparator == 'contains'
          infos = Info.where(candidate_id: candidates.ids, meta_key: 'certificates')
          infos = infos.to_a.delete_if { |info| info.word_in_meat_value_array? > value }
        end
      else

      end
    end
  end
end
