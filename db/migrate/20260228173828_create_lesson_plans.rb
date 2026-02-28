class CreateLessonPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :lesson_plans do |t|
      t.string :csv_uuid
      t.string :title
      t.string :discipline
      t.string :theme
      t.text :bncc_skills
      t.text :bncc_descriptions
      t.string :grade
      t.text :objectives
      t.text :materials
      t.text :steps
      t.string :duration
      t.string :url
      t.string :url_key
      t.string :bloom_taxonomy
      t.text :full_content
      t.boolean :evaluated, default: false

      t.timestamps
    end
    add_index :lesson_plans, :csv_uuid, unique: true
  end
end
