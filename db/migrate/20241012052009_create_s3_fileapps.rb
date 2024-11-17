class CreateS3Fileapps < ActiveRecord::Migration[7.2]
  def change
    create_table :s3_fileapps do |t|
      t.string :name
      t.string :content
      t.string :ssn
      t.timestamps
    end
  end
end
