class CreateTeacherReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :teacher_reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lesson_plan, null: false, foreign_key: true
      t.references :chosen_llm_evaluation, null: false, foreign_key: { to_table: :llm_evaluations }
      t.text :observation

      t.timestamps
    end
  end
end
