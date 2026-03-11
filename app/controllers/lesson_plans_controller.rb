class LessonPlansController < ApplicationController
  # Only authenticated users
  allow_unauthenticated_access only: []

  def evaluate_next
    # Get discipline from URL params
    @discipline = params[:discipline] || "Matemática"

    # Get first plan not evaluated
    @lesson_plan = LessonPlan.find_by(evaluated: false, discipline: @discipline)

    # Count plans to update progress bar
    @total_plans = LessonPlan.where(discipline: @discipline).count
    @evaluated_count = LessonPlan.where(discipline: @discipline, evaluated: true).count

    if @lesson_plan
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

    # Go back to the evaluation page with a success message
    redirect_to root_path(discipline: @lesson_plan.discipline), notice: "Avaliação salva com sucesso!"
  end

  def history
    # Get all reviews of the current user, including associated lesson plans and evaluations, ordered by most recent
    @reviews = Current.user.teacher_reviews.includes(:lesson_plan, :chosen_llm_evaluation).order(created_at: :desc)

    # If there's a search query, filter reviews by lesson plan title
    if params[:query].present?
      @reviews = @reviews.joins(:lesson_plan).where("lesson_plans.title ILIKE ?", "%#{params[:query]}%")
    end
  end
end