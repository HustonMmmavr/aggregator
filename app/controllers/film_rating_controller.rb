class FilmRatingController < ApplicationController

  # to fims_rat and films
  def set_rating()
    filmId = params[:filmId]
    filmRating = params[:filmRating]
  end

  def get_rating()
    filmId = params[:filmId]
  end

  def get_users_by_film()
    userId = params[:userId]
  end

  def get_films_by_user()
    filmId = params[:id]
  end
end
