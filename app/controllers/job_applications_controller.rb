require 'open-uri'

class JobApplicationsController < ApplicationController
  before_action :authenticate_user!

  def create
    job = Job.find(params[:job_id])
    if params[:applications].present? && params[:applications][:attachments].present?
      attachments = params[:applications][:attachments]
      attachments.each do |attachment|
        cloudinary_result = Cloudinary::Uploader.upload(attachment.tempfile)
        cloudinary_url = cloudinary_result["url"]
        result_text = convertapi_call(cloudinary_url)
        next if result_text.nil?

        candidate = Candidate.new(attachment: cloudinary_url,
                                  user: job.user)
        ParserService.new.parse_linkedin_cv_from_text(candidate,
                                                      result_text.force_encoding('UTF-8'))
        next if candidate.id.nil?

        @job_application = JobApplication.create(candidate: candidate, job: job,
                                                date: Date.today.to_datetime)
        suitability = SuitabilityService.new.add_suitability_to_application(@job_application)
        @job_application.suitability = suitability
        @job_application.save!
        authorize @job_application
      end
    else
      # puts "The upload didn't contain any attachments - sorry"
      authorize JobApplication.new(job: job)
      puts "The upload didn't contain any attachments - sorry"
    end
    ### => Here loop ends

    # => The below should be replaced with logic confirming all jobapplications have saved
    redirect_to job_path(job)
  end

  def update
    @job_application = JobApplication.find(params[:id])
    @jobs = current_user.jobs
    authorize @job_application
    status = params[:q]
    if ['accept', 'reject'].include?(status)
      @job_application.status = status
      @job_application.save
    else
      @job_application.id = nil
    end
  end

  private

  def convertapi_call(cloudinary_url)
    ConvertApi.config.api_secret = ENV['CONVERT_API_SECRET']
    result = ConvertApi.convert('txt', {
                                  File: cloudinary_url,
                                  PageRange: '1-20',
                                  LineLength: '2000',
                                  EndLineChar: 'mac'
                                },
                                from_format: 'pdf')
    open(result.file.url).read
  end
end
