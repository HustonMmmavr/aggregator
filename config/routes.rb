Rails.application.routes.draw do
  get '/film/:id', to: 'film#film', :as => :film
  get '/films/:page', to: 'film#films', :as => :films
  delete '/delete_film/:id', to: 'film#delete_film', :as => :delete_film
  post '/add_film', to: 'film#add_film', :as => :add_film
  get '/get_films_count', to: 'film#get_films_count', :as => :get_films_count

  post '/set_rating', to: 'film_rating#set_rating', :as => :set_ratin
  # get '/get_rating/:id', to: 'film_raing#get_raing'
  get '/users_rated_film/:id', to: 'film_rating#get_users_by_film', :as => :get_users_by_films
  get '/films_rated_by_user/:id', to: 'film_rating#get_films_by_user', :as => :get_films_by_user

  post '/signup', to: 'user#signup'
  post '/login', to: 'user#login'
  get '/get_user/:id', to: 'user#get_user'
end
