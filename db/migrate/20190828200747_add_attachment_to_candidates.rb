class AddAttachmentToCandidates < ActiveRecord::Migration[5.2]
  def change
    add_column :candidates, :attachment, :string
  end
end
