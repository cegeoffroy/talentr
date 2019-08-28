require 'open-uri'

class JobApplicationsController < ApplicationController
  before_action :authenticate_user!
  def create
    job = Job.find(params[:job_id])
    result = convertapi_call("https://res.cloudinary.com/dqh0reqn3/image/upload/v1566987213/cvtest.pdf")
    # candidate = Parser.parse(result)
    # => result is now a txt
    # => the candidate creation will be replaced with the actual PDF parsing method
    candidate = Candidate.create(name: Faker::Name.name,
                                 email: Faker::Internet.free_email,
                                 linkedin_url: 'https://www.linkedin.com/in/dmytrotarasenko/')
    @job_application = JobApplication.new(candidate: candidate, job: job,
                                          date: Date.today.to_datetime,
                                          suitability: (1..100).to_a.sample)
    authorize @job_application
    if @job_application.save
      redirect_to candidate_path(candidate)
    else
      redirect_to job_path(job)
    end
  end

  private

  def convertapi_call(cloudinary_url)
    ConvertApi.config.api_secret = ENV['CONVERT_API_SECRET']
    result = ConvertApi.convert('txt', {
                                  File: cloudinary_url,
                                  PageRange: '1-20'
                                },
                                from_format: 'pdf')
    open(result.file.url).read
  end
end
