class CreateApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :applications do |t|
      t.references :candidate, foreign_key: true
      t.references :job, foreign_key: true
      t.datetime :date
      t.string :status
      t.integer :suitability

      t.timestamps
    end
  end
end
