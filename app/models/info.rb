class Info < ApplicationRecord
  belongs_to :candidate
  serialize :meta_value
  include PgSearch::Model
  pg_search_scope :search_by_meta_value,
    against: [ :meta_value ],
    using: {
      tsearch: { prefix: true } # <-- now `superman batm` will return something!
    }

  def experience_duration
    duration = 0
    experiences = meta_value[:items]
    experiences.each do |exp|
      next unless exp[:start_date] && exp[:end_date]

      start_date = exp[:start_date]
      exp[:end_date] == 'Present' ? end_date = DateTime.now : end_date = exp[:end_date]
      duration += ((end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)) / 12
    end
    duration
  end

  def similar_role_experience_duration(job)
    duration = 0
    experiences = meta_value[:items]
    experiences.each do |exp|
      next unless exp[:start_date] && exp[:end_date]
      next unless relevant_role?(exp, job.title)

      start_date = exp[:start_date]
      exp[:end_date] == 'Present' ? end_date = DateTime.now : end_date = exp[:end_date]
      duration += ((end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)) / 12
    end
    duration
  end

  def word_in_meta_value_array?(word)
    array = meta_value
    if array
      array.each do |item|
        # @score += @base * coef if item.downcase.include?(word)
        return true if item.downcase.include?(word)
      end
    end
    return false
  end

  def education_duration
    duration = 0
    eds = meta_value[:education]
    eds.each do |ed|
      next unless ed[:start_date] && ed[:end_date]

      start_date = ed[:start_date]
      end_date = ed[:end_date]
      duration += ((end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)) / 12
    end
    duration
  end

  def relevant_role?(exp, title)
    title.downcase.split(" ").each do |word|
      return true if exp[:position].downcase.include?(word) || exp[:description].downcase.include?(word)
    end
    false
  end

  def last_education
    eds = meta_value[:education]
    eds.first[:institute]
  end

  def last_workplace
    eds = meta_value[:items]
    if !eds.first[:company].blank?
      eds.first[:company]
    else
      eds.first[:position]
    end
  end
end
