class CreateInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :infos do |t|
      t.references :candidate, foreign_key: true
      t.string :meta_key
      t.string :meta_value

      t.timestamps
    end
  end
end
