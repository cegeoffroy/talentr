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

        end
      when "Suitability Score"

      when "Experience Years"

      when "Same Role Experience Years"

      when "Education Years"

      when "Skills"

      else

      end
    end
  end
end
