class RenameApplicationsTableToJobApplications < ActiveRecord::Migration[5.2]
  def change
    rename_table :applications, :job_applications
  end
end
