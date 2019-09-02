class SuitabilityService
  def add_suitability_to_application(job_application)
    @score = 0
    @job_application = job_application
    @candidate = @job_application.candidate
    @job_title = @job_application.job.title
    @split_title = @job_title.split(' ')
    @split_title.map! do |w|
      w.downcase.strip
    end
    @keywords = []
    @job_application.job.keywords.to_a.each { |keyword| @keywords << keyword.word }
    @keywords.map! do |w|
      w.downcase.strip
    end
    call_calculators
    return @score.round
  end

  private

  def words_in_histogram(words)
    histogram = @candidate.infos.where(meta_key: 'histogram')[0].meta_value
    words.each do |word|
      # @score += (histogram[word] / @base * 100) if histogram.key?(word)
      @score += 1 if histogram.key?(word)
    end
  end

  def words_in_array(words, array_name, coef = 2)
    array = @candidate.infos.where(meta_key: array_name)[0].meta_value
    words.each do |word|
      array.each do |item|
        # @score += @base * coef if item.downcase.include?(word)
        @score += coef if item.downcase.include?(word)
      end
    end
  end

  def words_in_experience(words, coef = 2)
    exp_array = @candidate.infos.where(meta_key: 'experience')[0].meta_value[:items]
    exp_array.each do |exp|
      words.each do |word|
        if exp[:position].downcase.include?(word)
          exp[:end_date] == 'Present' ? end_date = DateTime.now : end_date = exp[:end_date]
          start_date = exp[:start_date]
          duration = ((end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)) / 12
          @score += (coef * duration)
        elsif exp[:description].downcase.include?(word)
          start_date = exp[:start_date]
          exp[:end_date] == 'Present' ? end_date = DateTime.now : end_date = exp[:end_date]
          duration = ((end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)) / 12
          @score += (coef * duration)
        end
      end
    end
  end

  def words_in_education(words, coef = 2)
    eds_array = @candidate.infos.where(meta_key: 'education')[0].meta_value[:education]
    eds_array.each do |ed|
      words.each do |word|
        # @score += 100.to_f * coef * 2 if ed[:subject].downcase.include?(word)
        @score += coef if ed[:subject].downcase.include?(word)
      end
    end
  end

  def call_calculators
    words_in_histogram(@split_title)
    words_in_histogram(@keywords)
    words_in_array(@split_title, 'skills')
    words_in_array(@split_title, 'certificates')
    words_in_array(@split_title, 'honors')
    words_in_array(@keywords, 'skills', 2.5)
    words_in_array(@keywords, 'certificates')
    words_in_array(@keywords, 'honors')
    words_in_experience(@keywords, 2.5)
    words_in_experience(@split_title, 2.5)
    words_in_education(@keywords)
    words_in_education(@split_title)
  end
end
