class CreateNominations < ActiveRecord::Migration[6.0]
  def change
    create_table :nominations do |t|
      t.string :status
      t.date :nomination_date
      t.text :comments
      t.references :nominatable, polymorphic: true, null: false
      t.references :team_member, null: false, foreign_key: true

      t.timestamps
    end
  end
end
