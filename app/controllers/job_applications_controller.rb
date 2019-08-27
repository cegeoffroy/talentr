class JobApplicationsController < ApplicationController
  before_action :authenticate_user!
  def create
    job = Job.find(params[:job_id])
    # => the candidate creation will be replaced with the actual PDF parsing method
    candidate = Candidate.create(name: Faker::Name.name,
                                 email: Faker::Internet.free_email,
                                 linkedin_url: 'https://www.linkedin.com/in/dmytrotarasenko/')
    @job_application = JobApplication.new(candidate: candidate, job: job,
                                          date: Date.today.to_datetime,
                                          status: 'pending',
                                          suitability: (1..100).to_a.sample)
    authorize @job_application
    if @job_application.save
      redirect_to candidate_path(candidate)
    else
      redirect_to job_path(job)
    end
  end
end
