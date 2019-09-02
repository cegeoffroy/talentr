KEYWORDS = %w(JavaScript Sales Remote Tech Ruby French Billingual Product Agile
              Scrum App\ Development Excel Marketing Google\ Analytics)

JOB_TITLES = %w(Product\ Manager Business\ Development\ Representative Web\ Developer)
UNIVERSITIES = %w(University\ of\ Surrey University\ of\ Oxford University\ of\ Cambridge
                  UCL Kings\ College)
SKILLS = %w(Accounting Enterpreneurship Microsoft\ Office Ruby Investment Web\ Development)

URLS = %w(http://res.cloudinary.com/dqh0reqn3/image/upload/v1567439799/uy2orz3gm2esrr5r2vqq.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567431718/die0teufqwqcgakqidmh.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567439553/lrk96piy114vjhzgaufa.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567440193/zuvito0egrckudlinkwh.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567440873/a3qwnfpcjhnedonu2qp9.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567441097/fujy7fktrmhs6gl0y6tp.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567441398/wmnu8a4edguf1ehsyq6s.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567441462/c2rc9f3iu0muiwdglxq0.pdf
         http://res.cloudinary.com/dqh0reqn3/image/upload/v1567441516/sjsnnl9ij7dqff74sedd.pdf)

def get_text(url)
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

JobApplication.destroy_all
JobKeyword.destroy_all
Keyword.destroy_all
Info.destroy_all
Candidate.destroy_all
User.destroy_all
Job.destroy_all

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
  2.times do
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
  sample = URLS
  puts 'creating 7 candidates per job ...'
  7.times do
    # below returns what it deletes so there can never be duplicate applicants to the same job
    # url = sample.delete_at(rand(sample.length))
    url = sample.sample
    text = get_text(url)
    candidate = Candidate.new(attachment: url,
                              user: job.user)
    ParserService.new.parse_linkedin_cv_from_text(candidate, text)
    # c = Candidate.new(name: Faker::Name.name,
    #                  email: Faker::Internet.free_email,
    #                  linkedin_url: 'https://www.linkedin.com/in/dmytrotarasenko/')
    #c.user = job.user
    # c.save!
    # Info.create(candidate: c, meta_key: "experience", meta_value: (0..10).to_a.sample)
    # Info.create(candidate: c, meta_key: "education", meta_value: UNIVERSITIES.sample)
    # Info.create(candidate: c, meta_key: "tagline", meta_value: Faker::GreekPhilosophers.quote)
    # Info.create(candidate: c, meta_key: "language", meta_value: "English")
    # Info.create(candidate: c, meta_key: "skill", meta_value: SKILLS.sample)
    application = JobApplication.create(job: job, candidate: candidate,
                                        date: Date.today.to_datetime - (1..20).to_a.sample.days,
                                        status: "pending")
    suitability = SuitabilityService.new.add_suitability_to_application(application)
    application.suitability = suitability
    puts "created candidate"
  end
  puts '7 candidates per job created!'

end






