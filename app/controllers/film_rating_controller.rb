# require_dependency "#{Rails.root.join('app', 'services', 'publisher.rb')}"

class FilmRatingController < ApplicationController
  @@film_rating_params = ['userId', 'filmId', 'filmRating']
  @@page = "1"


  def set_rating()
    p cookies['access_token']
    p 'sf'
    res = login_user(request, params, cookies)
    if res != nil
      if res[:url]
        return redirect_to res[:url]
      end
    end
    p 'sg'
    res = send_req_with_auth(@@url_user_service, 'get_user_by_token', 'post', {:access_token => cookies['access_token']})
    p 'd'
    p res[:user]
    # login_user()
    filmId = params[:filmId]
    filmRating = params[:filmRating]


    p filmId
    p filmRating
    # its a crutch
    params[:userId] = res[:user]['userId'].to_s
    ######################################
    @@film_rating_params.each do |key|
      check = is_parameter_valid key, params[key], @@int_regexp
      if check != true
        return render :json => {:respMsg => check}, :status => 400
      end
    end

    # request to film_rating if its not availible then we end work
    params_to_fr = {:userId => params[:userId], :filmId => params[:filmId],
      :filmRating => params[:filmRating]}
    res = send_req_with_auth(@@url_film_rating_service, 'set_rating','post',params_to_fr)
    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end
    fr_res = res
    # trying to save rating to film, if its not availible then rollback
    params_to_fs = {:filmId => params[:filmId].to_s, :filmRating => res[:filmAvgRating].to_s}
    avgRating = res[:filmAvgRating]
    res = send_req_with_auth(@@url_film_service, 'update_film', 'post', params_to_fs )
    if res[:status] != 200
      #if rating updated, then change for old, else delete rating
      if fr_res[:isUpdated] == true
        params_to_fr[:filmRating] = fr_res[:oldData]
        send_req_with_auth(@@url_film_rating_service, 'set_rating', 'post', params_to_fr)
      else
        send_req_with_auth(@@url_film_rating_service, 'delete_rating', 'post',params_to_fr)
      end
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end
    render :json => {:respMsg => "Ok", :filmAvgRating => avgRating}, :status => 200
  end

  def get_users_by_film()
    filmId = params[:id]
    check_film_id = is_parameter_valid 'id', filmId, @@int_regexp
    if check_film_id != true
      return render :json => {:respMsg => 'film id is inavlid'}, :status => 400
    end

    # p filmId
    res = send_req_with_auth(@@url_film_rating_service, 'get_linked_objects', 'get', filmId,
    {:search_by => 'film_id'})

    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end

    user_ids = res[:userId]
    p user_ids
    res = send_req_with_auth(@@url_film_service, 'get_film', 'get', filmId)
    p res
    if res[:status] != 200
      film = "Error with film service"
    else
      film = res[:film]
    end

    users = []
    user_ids.each do |id|
      p id
      res = send_req_with_auth(@@url_user_service, 'get_user_by_id', 'get', id)
      p res
      if res[:status] < 500
        users.push(res[:user])
      end
    end

    return render :json => {:film => film, :users_rated_this_film => users}, :status => 200
  end

  def get_films_by_user()
    userId = params[:id]

    check_film_id = is_parameter_valid 'id', userId, @@int_regexp
    if check_film_id != true
      return render :json => {:respMsg => 'uesr id is invalid'}, :status => 400
    end

    res = send_req_with_auth(@@url_film_rating_service, 'get_linked_objects', 'get', userId,
    {:search_by => 'user_id'})
    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end

    film_ids = res[:filmId]

    res = send_req_with_auth(@@url_user_service, 'get_user_by_id', 'get', userId)
    if res[:status] != 200
      user = "error with user service"
    else
      user = res[:user]
    end

    films = []
    film_ids.each do |id|
      res = send_req_with_auth(@@url_film_service, 'get_film', 'get', id)
      if res[:status] < 500
        films.push(res[:film])
      end
    end

    return render :json => {:user => user, :films_rated_by_user => films}, :status => 200
  end
end
