class FilmController < ApplicationController
  @@films_on_page = 5
  def films()
    page = Integer(params[:page])
    res = get_films_count
    if res[:status] != 200
      return render :json => {:respMsg => "service not avaliable"}, :status => res[:status]
    end

    res = send_req(@@url_film_service, 'get_films', 'get', [page * @@films_on_page, @@films_on_page])
    render :json => {:data => res[:films]}, :status => 200
  end

  def add_film()
    res = send_req(@@url_film_service, 'add_film', 'post',
    params)
    if res != 200.to_s
    end

    render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
  end


  def film()
    id = params[:id]
    res = send_req(@@url_film_service, 'get_film', 'get', [id])
    # if res != 200.to_s
      # return render :json => {:respMsg => res['respMsg']}, :status => res['status']
    # end
    render :json => {:data => res[:film]}, :status => 200
  end

  def get_films_count()
    res = send_req(@@url_film_service, 'get_films_count', 'get')
    if res['status'] != 200.to_s
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end
    @films_count = res[:filmsCount]
    res
  end

  # to films and films_rating
  def delete_film()
    id = params[:id]
    res = send_req(@@url_film_rating_service, 'delete_film_rating', 'post', {:filmId => id})
    p res
    res = send_req(@@url_film_service, 'delete_film', 'delete', id)
    return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
  end
end
