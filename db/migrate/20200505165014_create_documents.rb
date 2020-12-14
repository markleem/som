class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.string :title
      t.date :publication_date
      t.integer :security_level

      t.timestamps
    end
  end
end
