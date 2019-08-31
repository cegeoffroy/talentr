require 'open-uri'

class JobApplicationsController < ApplicationController
  include ParserHelper
  before_action :authenticate_user!

  def create
    c = parse
    raise
    job = Job.find(params[:job_id])
    attachments = params[:applications][:attachments]
    attachments.each do |attachment|
      cloudinary_result = Cloudinary::Uploader.upload(attachment.tempfile)
      cloudinary_url = cloudinary_result["url"]
      ### => here loop begins for each PDF uploaded
      # TODO: upload to cloudinary - receive a link
      # cloudinary_url = "https://res.cloudinary.com/dqh0reqn3/image/upload/v1566987213/cvtest.pdf"
      # result = convertapi_call(cloudinary_url)
      # => result is now a string
      # TODO: candidate = Parser.parse(result)
      candidate = Candidate.new(name: Faker::Name.name,
                                email: Faker::Internet.free_email,
                                linkedin_url: 'https://www.linkedin.com/in/dmytrotarasenko/',
                                attachment: cloudinary_url,
                                user: job.user)
      candidate.save!
      @job_application = JobApplication.new(candidate: candidate, job: job,
                                            date: Date.today.to_datetime,
                                            suitability: (1..100).to_a.sample)
      authorize @job_application
      @job_application.save!
    end
    ### => Here loop ends

    # => The below should be replaced with logic confirming all jobapplications have saved
    if @job_application.save
      redirect_to job_path(job)
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
