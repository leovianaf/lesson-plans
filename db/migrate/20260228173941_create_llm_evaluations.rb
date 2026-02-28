class CreateLlmEvaluations < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_evaluations do |t|
      t.references :lesson_plan, null: false, foreign_key: true
      t.string :ai_model_name
      t.integer :score
      t.text :rationale

      t.timestamps
    end
  end
end
