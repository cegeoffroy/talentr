module ParserHelper
  def parse_linkedin_cv_from_text
    candidate = Candidate.new
  end

  def remove_pagination(text)
    arr = text.split(/Page \d+ of \d+/)
    arr.map! { |item| item.strip }
    arr.join("\n")
  end

  def line_by_line(text)
    text.split("\n")
  end

  def email?(website, text)
    index = text.index(website)
    text[index + website.length] == '@' || text[index - 1] == '@'
  end

  def get_name(text)
    lines = line_by_line(text)
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

  def get_tagline(text)
    lines = line_by_line(text)
    index = lines.find_index('Summary')
    return nil unless index

    if lines[index - 1] == ''
      tagline = lines[index - 2]
    else
      tagline = lines[index - 1]
    end
    tagline
  end

  def get_email(text)
    text.match(/[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/)[0]
  end

  def get_phone_number(text)
    phone_number = nil
    end_index = text.index('Mobile')
    return phone_number unless end_index

    break_index = end_index
    break_index -= 1 until text[break_index] == "\n"
    phone_number = text.slice(break_index..end_index)
    phone_number.gsub(/[^+\d]/, '')
  end

  def get_websites(text)
    hash = {}
    arr = []
    sites = text.scan(/(?<full>(\s|^)(www\.)*(\w+\.)+\w{2,3}(\/|\w|\d)+)/)
    sites.each do |site|
      site = site[0]
      site.chomp!
      site.gsub!("\n", '')
      next if email?(site, text)

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

  def stop_word?(word, file_name)
    # true or false reading from stop_words.txt
    word_array = []
    File.open(file_name, "r").each_line do |line|
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

  def exclude_word?(word, stop_words_file_name)
    stop_word?(word, stop_words_file_name) || number?(word) || non_word_only?(word) || word.empty?
  end

  def get_frequency_histogram(text, stop_words_file_name)
    histogram = Hash.new(0)
    text.chomp.split("\n").each do |line|
      line.chomp.split(' ').each do |word|
        clean_word = word.gsub(/(\W$)|(\Ws$)/, "").downcase
        histogram[clean_word] += 1 unless exclude_word?(clean_word, stop_words_file_name)
      end
    end
    histogram.sort_by { |_key, value| - value }.to_h
  end

  def get_top_skills(text)
    if text.index('Top Skills')
      skills = []
      init_position = text.index('Top Skills') + 10
      sliced_text = text.slice(init_position..-1)
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

  def get_certifications(text)
    certifications = []
    if text.index('Certifications')
      init_position = text.index('Certifications') + 14
      sliced_text = text.slice(init_position..-1)
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

  def get_honors(text)
    honors = []
    if text.index('Honors-Awards')
      init_position = text.index('Honors-Awards') + 13
      sliced_text = text.slice(init_position..-1)
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

  def get_languages(text)
    hash = {}
    if text.index('Languages')
      arr = []
      init_position = text.index('Languages') + 9
      sliced_text = text.slice(init_position..-1).strip
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

  def get_summary(text)
    summary_string = nil
    if text.index('Summary')
      init_position = text.index('Summary') + 7
      sliced_text = text.slice(init_position..-1)
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

  def get_education(text)
    hash = {}
    arr = []
    index = text =~ /\neducation\n/i
    return hash unless index

    education = text[index..-1].strip.split("\n")
    education.delete('')
    education.delete('Education')
    education.each_slice(2).to_a.each do |edu|
      institute = edu[0]
      detail = edu[1]
      full_data = detail.match(/(?<subject>.*) · \((?<start_year>\d+)[^a-zA-Z0-9]+(?<end_year>\d+)\)/)
      if full_data
        start_year = full_data[:start_year].to_i
        end_year = full_data[:end_year].to_i
        subject = full_data[:subject]
        arr << { institute: institute, subject: subject,
                 start_year: start_year, end_year: end_year}
      else
        arr << { institute: institute, subject: detail }
      end
    end
    hash[:education] = arr
    hash
  end

  content = File.read('./big-cv.txt')
  content = remove_pagination(content)
  content_historgram = get_frequency_histogram(content, './stop-words.txt')
  tagline = get_tagline(content)
  p tagline
  p content_historgram
  email = get_email(content)
  p email
  websites = get_websites(content)
  p websites
  skills = get_top_skills(content)
  p skills
  cs = get_certifications(content)
  p cs
  name = get_name(content)
  p name
  phone_number = get_phone_number(content)
  p phone_number
  honors = get_honors(content)
  p honors
  languages = get_languages(content)
  p languages
  summary = get_summary(content)
  p summary
  education = get_education(content)
  p education
end
