Rails.application.routes.draw do

  # api part
  scope '/api' do
    get '/film/:id', to: 'film#film', :as => :film
    get '/films/:page', to: 'film#films', :as => :films
    delete '/delete_film/:id', to: 'film#delete_film', :as => :delete_film
    post '/add_film', to: 'film#add_film', :as => :add_film
    get '/get_films_count', to: 'film#get_films_count', :as => :get_films_count

    post '/set_rating', to: 'film_rating#set_rating', :as => :set_ratin
    get '/users_rated_film/:id', to: 'film_rating#get_users_by_film', :as => :get_users_by_films
    get '/films_rated_by_user/:id', to: 'film_rating#get_films_by_user', :as => :get_films_by_user

    post '/signup', to: 'user#signup', :as => :signup
    get '/get_user/:id', to: 'user#get_user', :as => :get_user
    get '/get_user_by_nick/:nick', to: 'user#get_user_by_nick', :as =>:user_by_nick

    get '/login', to: 'user#login', :as => :api_login
  end

  # ui
  get '/signup', to: 'user#signup_get', :as => :signup_ui
  post '/signup', to: 'user#signup_post', :as => :signup_ui_post
  get '/login', to: 'user#login_get', :as => :login_get
  post '/login', to: 'user#login_post', :as => :login_post
  get '/add_film', to: 'film#add_film_get', :as => :add_film_get
  post '/add_film', to: 'film#add_film_post', :as => :add_film_post
  get '/film/:id', to: 'film#film_get', :as => :film_get
  get '/films/:page', to: 'film#films_get', :as => :films_get_p
  get '/get_user_by_nick/:nick', to: 'user#get_user_by_nick_ui', :as =>:user_by_nick_ui

  get '/', to: 'film#films_get', :as => :root
  get '/:page', to: 'film#films_get', :as => :root_films
end
