class CreateTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :teams do |t|
      t.string :description
      t.string :format_style

      t.timestamps
    end
  end
end
