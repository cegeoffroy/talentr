class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :title
      t.datetime :due_date
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
