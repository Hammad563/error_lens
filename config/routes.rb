ErrorLens::Engine.routes.draw do
  root to: "errors#index"

  resources :errors, only: [:index, :show, :destroy] do
    member do
      post :resolve
      post :unresolve
    end

    resources :occurrences, only: [:show]
  end
end
