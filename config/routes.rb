Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # get '/func', to: 'film#func'
  get '/film/:id', to: 'film#film'
  get '/films/:page', to: 'film#films'
  delete '/delete_film/:id', to: 'film#delete_film'
end
