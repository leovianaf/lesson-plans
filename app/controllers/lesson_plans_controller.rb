class LessonPlansController < ApplicationController
  # Only authenticated users
  allow_unauthenticated_access only: []

  def evaluate_next
    # Get first plan not evaluated
    @lesson_plan = LessonPlan.find_by(evaluated: false)

    if @lesson_plan
      # Shuffle LLM evaluations to avoid bias
      @evaluations = @lesson_plan.llm_evaluations.shuffle
    end
  end

  def save_evaluation
    @lesson_plan = LessonPlan.find(params[:id])

    # Creates the TeacherReview
    TeacherReview.create!(
      user: Current.user, # Gets the authenticated user
      lesson_plan: @lesson_plan,
      chosen_llm_evaluation_id: params[:chosen_llm_evaluation_id],
      observation: params[:observation]
    )

    @lesson_plan.update!(evaluated: true)

    redirect_to root_path, notice: "Avaliação salva com sucesso!"
  end
end