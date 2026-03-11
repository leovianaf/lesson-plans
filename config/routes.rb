Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  # Define the root path route ("/") to the evaluation page
  root "lesson_plans#evaluate_next"

  # Route to save the teacher's evaluation (review)
  patch "save_evaluation/:id", to: "lesson_plans#save_evaluation", as: :save_evaluation

  # Route to show the history of evaluated lesson plans
  get "historico", to: "lesson_plans#history", as: :history
end
