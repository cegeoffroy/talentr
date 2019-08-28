class AddDefaultStatusToJobApplications < ActiveRecord::Migration[5.2]
  def change
    change_column_default :job_applications, :status, 'pending'
  end
end
