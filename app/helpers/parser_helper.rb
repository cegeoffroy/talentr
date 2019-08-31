module ParserHelper
  def parse_linkedin_cv_from_text
    candidate = Candidate.new
  end

  def get_email(text)
    text.match(/[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/)[0]
  end

  def websites(text)
    hash = {}
    arr = []
    sites = text.scan(/(?<full>(\s|^)www\.(\w+\.)+\w{2,3}(\/|\w|\d)+)/)
    sites.each do |site|
      site = site[0]
      site.chomp!
      site.gsub!("\n", '')
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

  def frequency_histogram(text, stop_words_file_name)
    histogram = Hash.new(0)
    text.chomp.split("\n").each do |line|
      line.chomp.split(' ').each do |word|
        clean_word = word.gsub(/(\W$)|(\Ws$)/, "").downcase
        histogram[clean_word] += 1 unless exclude_word?(clean_word, stop_words_file_name)
      end
    end
    histogram.sort_by { |_key, value| - value }.to_h
  end

  def top_skills(text)
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

  # content = File.read('./dima-cv.txt')
  # content_historgram = frequency_histogram(content, './stop-words.txt')
  # p content_historgram
  # email = get_email(content)
  # p email
  # websites = websites(content)
  # p websites
  # skills = top_skills(content)
  # p skills
end
