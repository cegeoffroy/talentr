require 'open-uri'

class JobApplicationsController < ApplicationController
  before_action :authenticate_user!

  def create
    job = Job.find(params[:job_id])
    if params[:applications][:attachments]
      attachments = params[:applications][:attachments]
      attachments.each do |attachment|
        cloudinary_result = Cloudinary::Uploader.upload(attachment.tempfile)
        cloudinary_url = cloudinary_result["url"]
        result_text = convertapi_call(cloudinary_url)
        next if result_text.nil?

        candidate = Candidate.new(attachment: cloudinary_url,
                                  user: job.user)
        # open("new.txt", "w") do |file|
        #   file << result_text.force_encoding('UTF-8')
        # end
        ParserService.new.parse_linkedin_cv_from_text(candidate, result_text.force_encoding('UTF-8'))
        next if candidate.id.nil?

        @job_application = JobApplication.new(candidate: candidate, job: job,
                                              date: Date.today.to_datetime,
                                              suitability: (1..100).to_a.sample)
        authorize @job_application
        @job_application.save!
      end
    else
      puts "The upload didn't contain any attachments - sorry"
    end
    ### => Here loop ends

    # => The below should be replaced with logic confirming all jobapplications have saved
    redirect_to job_path(job)
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
