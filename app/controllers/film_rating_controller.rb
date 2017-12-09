class FilmRatingController < ApplicationController
  def set_rating()
    filmId = params[:filmId]
    filmRating = params[:filmRating]
    res = send_req(@@url_film_rating_service, 'set_rating', 'post',
      {:userId => params[:userId], :filmId => params[:filmId], :filmRating => params[:filmRating]})
    p res
    if res[:status] != 200

    end
    res = send_req(@@url_film_service, 'update_film', 'post',
      {:filmId => params[:filmId].to_s, :filmRating => res[:filmAvgRating].to_s} )
    if res['status'] != 200
    end
    render :json => {:respMsg => "Ok"}, :status => 200
  end

  def get_rating()
    filmId = params[:filmId]
    res = send_req(@@url_film_rating_service, 'get_rating', 'get', [filmId])
    if res[:status] != 200
    end
    res[:filmAvgRating]
  end

  def get_users_by_film()
    filmId = params[:id]
    p filmId
    res = send_req(@@url_film_rating_service, 'get_linked_objects', 'get', [filmId],
    {:search_by => 'film_id'})

    if res != 200
    end
    user_ids = res[:userId]

    res = send_req(@@url_film_service, 'get_film', 'get', [filmId])
    if res[:status] != 200
    end

    film = res[:film]

    users = []
    user_ids.each do |id|
      p id
      res = send_req(@@url_user_service, 'get_user_by_id', 'get', [id])
      p res
      if res[:status] == 200
        users.push(res[:user])
      end
    end

    return render :json => {:film => film, :users_rated_this_film => users}, :status => 200
  end

  def delete_film()
    id = params[:id]
    res = send_req(@@url_film_service, 'delete_film', 'delete', [id])
    p res
    res = send_req(@@url_film_rating_service, 'delete_film_rating', 'post', {:filmId => id})
    p res
  end

  def get_films_by_user()
    userId = params[:id]
    res = send_req(@@url_film_rating_service, 'get_linked_objects', 'get', [userId],
    {:search_by => 'user_id'})
    if res != 200
    end

    film_ids = res[:filmId]

    res = send_req(@@url_user_service, 'get_user_by_id', 'get', [userId])
    if res[:status] != 200
    end

    user = res[:user]

    films = []
    film_ids.each do |id|
      res = send_req(@@url_film_service, 'get_film', 'get', [id])
      if res[:status] == 200
        films.push(res[:film])
      end
    end

    return render :json => {:user => user, :films_rated_by_user => films}, :status => 200
  end
end
