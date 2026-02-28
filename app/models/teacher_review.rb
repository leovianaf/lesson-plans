class TeacherReview < ApplicationRecord
  belongs_to :user
  belongs_to :lesson_plan
  belongs_to :chosen_llm_evaluation, class_name: "LlmEvaluation"
end
