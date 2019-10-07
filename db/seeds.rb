env = "demo"

KEYWORDS = %w(JavaScript Sales Remote Tech Ruby SEO Product Agile
              Scrum App\ Development Excel Marketing Google\ Analytics)

JOB_TITLES = %w(Product\ Manager Business\ Development\ Representative Web\ Developer)
UNIVERSITIES = %w(University\ of\ Surrey University\ of\ Oxford University\ of\ Cambridge
                  UCL Kings\ College)
SKILLS = %w(Accounting Enterpreneurship Microsoft\ Office Ruby Investment Web\ Development)


URLS = %w(http://res.cloudinary.com/dqh0reqn3/image/upload/v1567431718/die0teufqwqcgakqidmh.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567439553/lrk96piy114vjhzgaufa.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567440873/a3qwnfpcjhnedonu2qp9.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567441097/fujy7fktrmhs6gl0y6tp.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567441462/c2rc9f3iu0muiwdglxq0.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567441516/sjsnnl9ij7dqff74sedd.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567763296/ruzx4c857x6qu6ghs7xf.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567764309/wbalrtlild2phedkxhkl.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567764774/lnjhkroestgowtzpkjtz.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567765026/hdapp72ijlj8eanqdly2.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567765136/eqwrloqxlmcgmofpdg2i.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567765254/bixo3gyhmrnw1nz4y0yu.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567765360/uhstvwmku9nskvyefsq4.pdf)
FILENAMES = %w(./ahmad.txt ./alwali.txt ./ben.txt ./dima.txt ./evia.txt ./shivam.txt ./wesley.txt
               ./rich-cv.txt )

def get_text_from_url(url)
  ConvertApi.config.api_secret = ENV['CONVERT_API_SECRET']
  result = ConvertApi.convert('txt', {
                                File: url,
                                PageRange: '1-20',
                                LineLength: '2000',
                                EndLineChar: 'mac'
                              },
                              from_format: 'pdf')
  text = open(result.file.url).read
  text.force_encoding('UTF-8')
end

def get_text_from_file(filename)
  File.read(filename)
end

JobApplication.destroy_all
JobKeyword.destroy_all
Keyword.destroy_all
Info.destroy_all
Candidate.destroy_all
User.destroy_all
Job.destroy_all

if env == "testing"
  puts "creating keywords ..."
  KEYWORDS.each do |keyword|
    Keyword.create(word: keyword)
  end
  puts "#{Keyword.count} keywords created!"

  puts 'Creating users ...'
  victor = User.new
  victor.first_name = "Victor"
  victor.last_name = "Ross"
  victor.email = 'victor@example.com'
  victor.password = "123456"
  victor.password_confirmation = "123456"
  victor.role = "owner"
  victor.company = "Disney"
  victor.save!

  charles = User.new
  charles.email = 'charles@example.com'
  charles.first_name = "Charles"
  charles.last_name = "Geoffroy"
  charles.password = "123456"
  charles.password_confirmation = "123456"
  charles.role = "owner"
  charles.company = "Le Wagon"
  charles.save!

  dima = User.new
  dima.email = 'dima@example.com'
  dima.first_name = "Dima"
  dima.last_name = "Tarasenko"
  dima.password = "123456"
  dima.password_confirmation = "123456"
  dima.role = "owner"
  dima.company = "Five Guys"
  dima.save!

  puts "Created #{User.count} users!"

  puts 'creating 2 jobs under each user ...'
  User.find_each do |user|
    3.times do
      job = Job.new(title: JOB_TITLES.sample,
                       due_date: Date.today.to_datetime + (1..100).to_a.sample.days)
      job.user = user
      job.save!
    end
  end
  puts '2 jobs per user created!'


  Job.find_each do |job|
    puts 'creating 4 keywords per job ...'
    4.times do
      JobKeyword.create(job: job, keyword: Keyword.order('RANDOM()').first)
    end
    puts '4 keywords per job created!'
    puts 'creating 7 candidates per job ...'
    filenames = FILENAMES.dup
    links = URLS.dup
    7.times do
      url = links.delete_at(rand(links.length))
      # text = get_text_from_url(url)
      filename = filenames.delete_at(rand(filenames.length))
      filename = "./test_cvs/#{filename}"
      # filename = FILENAMES.sample
      text = get_text_from_file(filename)
      candidate = Candidate.new(attachment: url,
                                user: job.user)
      ParserService.new.parse_linkedin_cv_from_text(candidate, text)

      application = JobApplication.create(job: job, candidate: candidate,
                                          date: Date.today.to_datetime - (1..20).to_a.sample.days,
                                          status: "pending")
      suitability = SuitabilityService.new.add_suitability_to_application(application)
      application.suitability = suitability
      application.save
      puts "created candidate"
    end
    puts '7 candidates per job created!'

  end
elsif env == "demo"
  puts "creating keywords ..."
  KEYWORDS.each do |keyword|
    Keyword.create(word: keyword)
  end
  puts "#{Keyword.count} keywords created!"

  puts 'Creating user taras3nko.dima@gmail.com ...'
  g_account = User.new
  g_account.first_name = "Dima"
  g_account.last_name = "Tarasenko"
  g_account.email = 'taras3nko.dima@gmail.com'
  g_account.password = "123456"
  g_account.password_confirmation = "123456"
  g_account.role = "owner"
  g_account.company = "Don't Worry!"
  g_account.save!

  puts 'Creating user dima@dontworry.com ...'
  normal_account = User.new
  normal_account.first_name = "Dima"
  normal_account.last_name = "Tarasenko"
  normal_account.email = 'dima@dontworry.com'
  normal_account.password = "123456"
  normal_account.password_confirmation = "123456"
  normal_account.role = "owner"
  normal_account.company = "Don't Worry!"
  normal_account.save!

  User.find_each do |user|
    product_job = Job.new(title: "Product Manager",
                     due_date: Date.today.to_datetime)
    product_job.user = user
    product_job.save!
    puts "Created Job #{product_job.title} for user #{user.email}"

    marketing_job = Job.new(title: "Marketing Executive",
                     due_date: Date.today.to_datetime + 6.days)
    marketing_job.user = user
    marketing_job.save!
    puts "Created Job #{marketing_job.title} for user #{user.email}"

    business_job = Job.new(title: "Business Development Representative",
                     due_date: Date.today.to_datetime + 63.days)
    business_job.user = user
    business_job.save!
    puts "Created Job #{business_job.title} for user #{user.email}"
  end

  Job.find_each do |job|
    puts 'creating 4 keywords per job ...'
    4.times do
      JobKeyword.create(job: job, keyword: Keyword.order('RANDOM()').first)
    end
  end


  User.find_each do |user|
    user.jobs.find_each do |job|
      case job.title
      when "Product Manager"
        links = URLS.dup
        links.each do |url|
          puts "Making api call"
          text = get_text_from_url(url)
          candidate = Candidate.new(attachment: url,
                                    user: job.user)
          puts "parsing"
          ParserService.new.parse_linkedin_cv_from_text(candidate, text)
          candidate.update(name: Faker::Name.name, email: Faker::Internet.free_email)
          application = JobApplication.create(job: job, candidate: candidate,
                                              date: Date.today.to_datetime - (1..5).to_a.sample.days,
                                              status: "pending")
          puts "calculating suitability"
          suitability = SuitabilityService.new.add_suitability_to_application(application)
          application.suitability = suitability
          application.save
          puts "created application from url"
        end
      when "Marketing Executive"
        7.times do

          candidate = Candidate.create(name: Faker::Name.name, email: Faker::Internet.free_email,
                                    attachment: "http://res.cloudinary.com/dqh0reqn3/image/upload/v1567439799/uy2orz3gm2esrr5r2vqq.pdf",
                                    user: user)
          application = JobApplication.create(job: job, candidate: candidate,
                                              date: Date.today.to_datetime - (1..15).to_a.sample.days,
                                              status: ["pending", 'accept', 'reject'].sample,
                                              suitability: (1..100).to_a.sample)
        end
      when "Business Development Representative"
        3.times do

          candidate = Candidate.create(name: Faker::Name.name, email: Faker::Internet.free_email,
                                    attachment: "http://res.cloudinary.com/dqh0reqn3/image/upload/v1567439799/uy2orz3gm2esrr5r2vqq.pdf",
                                    user: user)
          application = JobApplication.create(job: job, candidate: candidate,
                                              date: Date.today.to_datetime - (15..30).to_a.sample.days,
                                              status: ["pending", 'accept', 'reject'].sample,
                                              suitability: (1..100).to_a.sample)
        end
      end
    end
  end
end






