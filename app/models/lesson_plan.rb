class LessonPlan < ApplicationRecord
  has_many :llm_evaluations, dependent: :destroy

  has_one :teacher_review, dependent: :destroy
end