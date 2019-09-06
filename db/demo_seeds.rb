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

KEYWORDS = %w(JavaScript Sales Remote Tech Ruby French Billingual Product Agile
              Scrum App\ Development Excel Marketing Google\ Analytics)

URLS = %w(http://res.cloudinary.com/dqh0reqn3/image/upload/v1567439799/uy2orz3gm2esrr5r2vqq.pdf
          http://res.cloudinary.com/dqh0reqn3/image/upload/v1567431718/die0teufqwqcgakqidmh.pdf
          http://res.cloudinary.com/dqh0reqn3/image/upload/v1567439553/lrk96piy114vjhzgaufa.pdf
          http://res.cloudinary.com/dqh0reqn3/image/upload/v1567440193/zuvito0egrckudlinkwh.pdf
          http://res.cloudinary.com/dqh0reqn3/image/upload/v1567440873/a3qwnfpcjhnedonu2qp9.pdf
          http://res.cloudinary.com/dqh0reqn3/image/upload/v1567441097/fujy7fktrmhs6gl0y6tp.pdf
          http://res.cloudinary.com/dqh0reqn3/image/upload/v1567441398/wmnu8a4edguf1ehsyq6s.pdf
          http://res.cloudinary.com/dqh0reqn3/image/upload/v1567441462/c2rc9f3iu0muiwdglxq0.pdf
          http://res.cloudinary.com/dqh0reqn3/image/upload/v1567441516/sjsnnl9ij7dqff74sedd.pdf)

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

puts 'Creating user taras3nko.dima@gmail.com ...'
g_account = User.new
g_account.first_name = "Victor"
g_account.last_name = "Ross"
g_account.email = 'taras3nko.dima@gmail.com'
g_account.password = "123456"
g_account.password_confirmation = "123456"
g_account.role = "owner"
g_account.company = "Don't Worry!"
g_account.save!

puts 'Creating user dima@dontworry.com ...'
normal_account = User.new
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

  busines_job = Job.new(title: "Business Development Representative",
                   due_date: Date.today.to_datetime + 63.days)
  busines_job.user = user
  busines_job.save!
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
      links.each do |link|
        text = get_text_from_url(url)
        candidate = Candidate.new(attachment: url,
                                  user: job.user)
        ParserService.new.parse_linkedin_cv_from_text(candidate, text)
        candidate.update(name: Faker::Name.name, email: Faker::Internet.free_email)
        application = JobApplication.create(job: job, candidate: candidate,
                                            date: Date.today.to_datetime - (1..5).to_a.sample.days,
                                            status: "pending")
        suitability = SuitabilityService.new.add_suitability_to_application(application)
        application.suitability = suitability
        application.save
      end
    when "Marketing Executive"
      7.times do

        candidate = Candidate.create(name: Faker::Name.name, email: Faker::Internet.free_email,
                                  attachment: "http://res.cloudinary.com/dqh0reqn3/image/upload/v1567439799/uy2orz3gm2esrr5r2vqq.pdf",
                                  user: user)
        application = JobApplication.create(job: job, candidate: candidate,
                                            date: Date.today.to_datetime - (1..15).to_a,sample.days,
                                            status: ["pending", 'accept', 'reject'].sample,
                                            suitability: (1..100).sample)
      end
    when "Business Development Representative"
      3.times do

        candidate = Candidate.create(name: Faker::Name.name, email: Faker::Internet.free_email,
                                  attachment: "http://res.cloudinary.com/dqh0reqn3/image/upload/v1567439799/uy2orz3gm2esrr5r2vqq.pdf",
                                  user: user)
        application = JobApplication.create(job: job, candidate: candidate,
                                            date: Date.today.to_datetime - (15..30).to_a,sample.days,
                                            status: ["pending", 'accept', 'reject'].sample,
                                            suitability: (1..100).sample)
      end
    end
  end
end
