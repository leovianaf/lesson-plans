Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  # Define a página inicial como a tela de avaliação
  root "lesson_plans#evaluate_next"

  # Rota para receber o formulário com a nota do professor
  patch "save_evaluation/:id", to: "lesson_plans#save_evaluation", as: :save_evaluation
end
