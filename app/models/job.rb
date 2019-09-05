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
        arr = []
        if comparator == 'contains'
          infos = Info.where(candidate_id: candidates.ids, meta_key: 'full_text').search_by_meta_value(value)
          infos.each { |info| arr << info.candidate.id }
          all_results << arr
        end
      when "Suitability score"
        job_apps = nil
        arr = []
        if comparator == "more than"
          job_apps = JobApplication.where(candidate_id: candidates.ids).where("suitability > ?", value)
          p "hello #{job_apps}"
        elsif comparator == "les than"
          job_apps = JobApplication.where(candidate_id: candidates.ids).where("suitability < ?", value)
        elsif comparator == "exactly equals"
          job_apps = JobApplication.where(candidate_id: candidates.ids).where("suitability = ?", value)
        end
        job_apps.each { |job_app| arr << job_app.candidate.id } if job_apps
        all_results << arr
      when "Experience years"
        infos = Info.where(candidate_id: candidates.ids, meta_key: 'experience')
        arr = []
        if comparator == "more than"
          infos = infos.to_a.delete_if { |info| info.experience_duration < value.to_i }
        elsif comparator == "les than"
          infos = infos.to_a.delete_if { |info| info.experience_duration > value.to_i }
        elsif comparator == "exactly equals"
          infos = infos.to_a.delete_if { |info| info.experience_duration != value.to_i }
        end
        infos.each { |info| arr << info.candidate.id }
        all_results << arr
      when "Similar Role Experience years"
        infos = Info.where(candidate_id: candidates.ids, meta_key: 'experience')
        arr = []
        if comparator == "more than"
          infos = infos.to_a.delete_if { |info| info.similar_role_experience_duration(job) < value.to_i }
        elsif comparator == "les than"
          infos = infos.to_a.delete_if { |info| info.similar_role_experience_duration(job) > value.to_i }
        elsif comparator == "exactly equals"
          infos = infos.to_a.delete_if { |info| info.similar_role_experience_duration(job) != value.to_i }
        end
        infos.each { |info| arr << info.candidate.id }
        all_results << arr
      when "Education years"
        infos = Info.where(candidate_id: candidates.ids, meta_key: 'education')
        arr = []
        if comparator == "more than"
          infos = infos.to_a.delete_if { |info| info.education_duration < value.to_i }
        elsif comparator == "les than"
          infos = infos.to_a.delete_if { |info| info.education_duration > value.to_i }
        elsif comparator == "exactly equals"
          infos = infos.to_a.delete_if { |info| info.education_duration != value.to_i }
        end
        infos.each { |info| arr << info.candidate.id }
        all_results << arr
      when "Skills"
        arr = []
        if comparator == 'contains'
          infos = Info.where(candidate_id: candidates.ids, meta_key: 'skills')
          infos = infos.to_a.delete_if { |info| !info.word_in_meta_value_array?(value) }
          infos.each { |info| arr << info.candidate.id }
        end
        all_results << arr
      when "Certifications"
        arr = []
        if comparator == 'contains'
          infos = Info.where(candidate_id: candidates.ids, meta_key: 'certificates')
          infos = infos.to_a.delete_if { |info| info.word_in_meta_value_array?(value) }
          infos.each { |info| arr << info.candidate.id }
        end
        all_results << arr
      when "Accept"
        arr = []
        job_apps = JobApplication.where(candidate_id: candidates.ids).where(status: value)
        job_apps.each { |job_app| arr << job_app.candidate.id } if job_apps
        all_results << arr
      when "Reject"
        arr = []
        job_apps = JobApplication.where(candidate_id: candidates.ids).where(status: value)
        job_apps.each { |job_app| arr << job_app.candidate.id } if job_apps
        all_results << arr
      when 'Pending'
        arr = []
        job_apps = JobApplication.where(candidate_id: candidates.ids).where(status: value)
        job_apps.each { |job_app| arr << job_app.candidate.id } if job_apps
        all_results << arr
      end
    end
    all_results
  end
end
