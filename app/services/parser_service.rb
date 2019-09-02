class ParserService
  attr_accessor :stop_words_file_name
  @@stop_words_file_name = './app/helpers/stop-words.txt'

  def parse_linkedin_cv_from_text(candidate, text)
    @text = text
    @candidate = candidate
    @text = remove_pagination
    @histogram = parse_frequency_histogram
    @tagline = parse_tagline
    @email = parse_email
    @websites = parse_websites
    @skills = parse_top_skills
    @certificates = parse_certifications
    @name = parse_name
    @phone_number = parse_phone_number
    @honors = parse_honors
    @languages = parse_languages
    @summary = parse_summary
    @education = parse_education
    @experience = parse_experience
    @certificates = clean_category(@certificates)
    @skills = clean_category(@skills)
    @honors = clean_category(@honors)
    @languages = clean_category(@languages)
    append_candidate
    create_info
  end

  def append_candidate
    linkedin = @websites[:websites].find { |site| site[:origin] == 'linkedin' }[:url]
    @candidate.update(name: @name, email: @email, linkedin_url: linkedin)
    @candidate.save
  end

  def create_info
    Info.create(candidate: @candidate, meta_key: "phone_number", meta_value: @phone_number)
    Info.create(candidate: @candidate, meta_key: "websites", meta_value: @websites)
    Info.create(candidate: @candidate, meta_key: "histogram", meta_value: @histogram)
    Info.create(candidate: @candidate, meta_key: "tagline", meta_value: @tagline)
    Info.create(candidate: @candidate, meta_key: "full_text", meta_value: @text)
    Info.create(candidate: @candidate, meta_key: "skills", meta_value: @skills)
    Info.create(candidate: @candidate, meta_key: "certificates", meta_value: @certificates)
    Info.create(candidate: @candidate, meta_key: "honors", meta_value: @honors)
    Info.create(candidate: @candidate, meta_key: "languages", meta_value: @languages)
    Info.create(candidate: @candidate, meta_key: "summary", meta_value: @summary)
    Info.create(candidate: @candidate, meta_key: "education", meta_value: @education)
    Info.create(candidate: @candidate, meta_key: "experience", meta_value: @experience)
  end

  def remove_pagination
    @text.gsub!("\r", '')
    arr = @text.split(/Page \d+ of \d+/)
    arr.map!(&:strip)
    arr.join("\n")
  end

  def line_by_line
    @text.split("\n")
  end

  def email?(website)
    index = @text.index(website)
    @text[index + website.length] == '@' || @text[index - 1] == '@'
  end

  def parse_name
    lines = line_by_line
    index = lines.find_index('Summary')
    return nil unless index

    if lines[index - 1] == ''
      name = lines[index - 3]
      name = lines[index - 4] if name == "\n"
    else
      name = lines[index - 2]
    end
    name
  end

  def parse_tagline
    lines = line_by_line
    index = lines.find_index('Summary')
    return nil unless index

    if lines[index - 1] == ''
      tagline = lines[index - 2]
    else
      tagline = lines[index - 1]
    end
    tagline
  end

  def parse_email
    email_regex = /[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/
    @text.match(email_regex)[0]
  end

  def parse_phone_number
    phone_number = nil
    end_index = @text.index('Mobile')
    return phone_number unless end_index

    break_index = end_index
    break_index -= 1 until @text[break_index] == "\n"
    phone_number = @text.slice(break_index..end_index)
    phone_number.gsub(/[^+\d]/, '')
  end

  def parse_websites
    hash = {}
    arr = []
    sites = @text.scan(/(?<full>(\s|^)(www\.)*(\w+\.)+\w{2,3}(\/|\w|\d)+)/)
    sites.each do |site|
      site = site[0]
      site.chomp!
      site.gsub!("\n", '')
      next if email?(site)

      arr << if site.include?('linkedin')
               { url: site, origin: 'linkedin' }
             elsif site.include?('github')
               { url: site, origin: 'github' }
             elsif site.include?('facebook')
               { url: site, origin: 'facebook' }
             else
               { url: site, origin: 'unknown' }
             end
    end
    hash[:websites] = arr
    hash
  end

  def stop_word?(word)
    # true or false reading from stop_words.txt
    word_array = []
    File.open(@@stop_words_file_name, "r").each_line do |line|
      word_array << line.chomp
    end
    word_array.include?(word)
  end

  def number?(word)
    word.match?(/\d/)
  end

  def non_word_only?(word)
    word.match?(/^\W+$/)
  end

  def exclude_word?(word)
    stop_word?(word) || number?(word) || non_word_only?(word) || word.empty?
  end

  def parse_frequency_histogram
    histogram = Hash.new(0)
    @text.chomp.split("\n").each do |line|
      line.chomp.split(' ').each do |word|
        clean_word = word.gsub(/(\W$)|(\Ws$)/, "").downcase
        histogram[clean_word] += 1 unless exclude_word?(clean_word)
      end
    end
    histogram.sort_by { |_key, value| - value }.to_h
  end

  def parse_top_skills
    if @text.index('Top Skills')
      skills = []
      init_position = @text.index('Top Skills') + 10
      sliced_text = @text.slice(init_position..-1)
      if sliced_text[0] == "\n"
        final_position = sliced_text.index("\n\n")
        skills_string = sliced_text.slice!(0..final_position).strip
        skills_string.split("\n").each { |skill| skills << skill }
      elsif sliced_text[0] == ' '
        final_position = sliced_text.index("\n")
        skills_string = sliced_text.slice!(0..final_position).strip
        skills_string.split(' ').each { |skill| skills << skill }
      end
    end
  end

  def parse_certifications
    certifications = []
    if @text.index('Certifications')
      init_position = @text.index('Certifications') + 14
      sliced_text = @text.slice(init_position..-1)
      if sliced_text[0] == "\n"
        final_position = sliced_text.index("\n\n")
        certifications_string = sliced_text.slice!(0..final_position).strip
        certifications_string.split("\n").each { |c| certifications << c }
      elsif sliced_text[0] == ' '
        final_position = sliced_text.index("\n")
        certifications_string = sliced_text.slice!(0..final_position).strip
        certifications_string.split(' ').each { |c| certifications << c }
      end
    end
    certifications
  end

  def parse_honors
    honors = []
    if @text.index('Honors-Awards')
      init_position = @text.index('Honors-Awards') + 13
      sliced_text = @text.slice(init_position..-1)
      if sliced_text[0] == "\n"
        final_position = sliced_text.index("\n\n")
        honors_string = sliced_text.slice!(0..final_position).strip
        honors_string.split("\n").each { |h| honors << h }
      elsif sliced_text[0] == ' '
        final_position = sliced_text.index("\n")
        honors_string = sliced_text.slice!(0..final_position).strip
        honors_string.split(' ').each { |h| honors << h }
      end
    end
    honors
  end

  def parse_languages
    hash = {}
    if @text.index('Languages')
      arr = []
      init_position = @text.index('Languages') + 9
      sliced_text = @text.slice(init_position..-1).strip
      final_position = sliced_text.index("\n")
      languages_string = sliced_text.slice!(0..final_position).strip
      languages_array = languages_string.scan(/(?<language>[a-zA-Z]+ )(?<skill>\([a-zA-Z ]+\))/)
      languages_array.each do |item|
        arr << { language: item[0].strip, level: item[1].gsub(/(\(|\))/, '') }
      end
      hash[:languages] = arr
    end
    hash
  end

  def parse_summary
    summary_string = nil
    if @text.index('Summary')
      init_position = @text.index('Summary') + 7
      sliced_text = @text.slice(init_position..-1)
      if sliced_text[0..1] == "\n\n"
        final_position = sliced_text.index("\n\n\n")
        summary_string = sliced_text.slice!(0..final_position).strip
      elsif sliced_text[0] == "\n"
        final_position = sliced_text.index("\n\n")
        summary_string = sliced_text.slice!(0..final_position).strip
      end
    end
    summary_string
  end

  def parse_education
    hash = {}
    arr = []
    index = @text =~ /\neducation\n/i
    return hash unless index

    education = @text[index..-1].strip.split("\n")
    education.delete('')
    education.delete('Education')
    education.each_slice(2).to_a.each do |edu|
      institute = edu[0]
      detail = edu[1]
      full_data = detail.match(/(?<subject>.*) · \((?<start_year>\d+)[^a-zA-Z0-9]+(?<end_year>\d+)\)/)
      if full_data
        start_year = full_data[:start_year].to_i
        end_year = full_data[:end_year].to_i
        start_date = DateTime.new(start_year, 1, 1)
        end_date = DateTime.new(end_year, 1, 1)
        subject = full_data[:subject]
        arr << { institute: institute, subject: subject,
                 start_date: start_date, end_date: end_date }
      else
        arr << { institute: institute, subject: detail }
      end
    end
    hash[:education] = arr
    hash
  end

  def parse_experience
    dates_regex = /(?<start_date>(\b\d{1,2}\D{0,3})?\b(?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|(Nov|Dec)(?:ember)?)\D?(\d{1,2}\D?)?\D?((19[7-9]\d|20\d{2})|\d{2})) - ((?<end_date>(\b\d{1,2}\D{0,3})?\b(?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|(Nov|Dec)(?:ember)?)\D?(\d{1,2}\D?)?\D?((19[7-9]\d|20\d{2})|\d{2}))|(?<present>Present))/
    hash = {}
    arr = []
    exp_index = @text =~ /\nexperience\n/i
    ed_index = @text =~ /\neducation\n/i
    return hash unless exp_index && ed_index

    experience_string = @text[exp_index..ed_index]
    experience_array = experience_string.split("\n")
    experience_array.delete('')
    experience_array.delete('Experience')
    dates_indexes = []
    experience_array.each_with_index do |line, index|
      dates_indexes << index if line.match?(dates_regex)
    end
    dates_indexes.each_with_index do |index, date_index|
      line = experience_array[index]
      match_data = line.match(dates_regex)
      if match_data[:end_date]
        end_date_array = match_data[:end_date].split(' ')
        end_date = DateTime.new(end_date_array[1].to_i,
                                Date::MONTHNAMES.index(end_date_array[0]), 1)
      else
        end_date = match_data[:present]
      end
      start_date_array = match_data[:start_date].split(' ')
      start_date = DateTime.new(start_date_array[1].to_i,
                                Date::MONTHNAMES.index(start_date_array[0]), 1)
      data_hash = { start_date: start_date,
                    end_date: end_date }
      position = line =~ dates_regex
      if position.positive?
        info = line[0..position - 1].strip
        data_hash[:position] = info
      else
        position = experience_array[index - 1]
        if dates_indexes.include?(index - 2)
          cur_index = index - 2
          cur_index -= 2 while dates_indexes.include?(cur_index)
          company = experience_array[cur_index - 1]
        elsif dates_indexes.include?(index + 2)
          company = experience_array[index - 3]
        else
          company = experience_array[index - 2]
        end
        data_hash[:position] = position
        data_hash[:company] = company
      end
      if date_index != dates_indexes.length - 1
        description = experience_array[index + 1..dates_indexes[date_index + 1] - 3].join("\n")
      else
        description = experience_array[index + 1..-1].join("\n")
      end
      data_hash[:description] = description
      arr << data_hash
    end
    hash[:items] = arr
    hash
  end

  def clean_category(category_array)
    @tagline.split("\n").each { |e| category_array.delete(e) }
    category_array.delete(@name)
    @summary.split("\n").each { |e| category_array.delete(e) }
    category_array.delete("Summary")
    category_array
  end
end
