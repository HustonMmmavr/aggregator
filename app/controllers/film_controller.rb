class FilmController < ApplicationController
  @@films_on_page = 5
  def films()
    page = Integer(params[:page])

    res = send_req(@@url_film_service, 'get_films', 'get', [page * @@films_on_page, @@films_on_page])

    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end

    render :json => {:data => res[:films]}, :status => 200
  end

  def add_film()
    p params[:film]
    res = send_req(@@url_film_service, 'add_film', 'post', params[:film])
    p res
    if res != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end

    render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
  end


  def film()
    id = params[:id]

    res = send_req(@@url_film_service, 'get_film', 'get', id)
    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end
    render :json => {:data => res[:film]}, :status => 200
  end

  def get_films_count()
    res = send_req(@@url_film_service, 'get_films_count', 'get')
    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end
    @films_count = res[:filmsCount]
    render :json => {:filmsCount => @films_count}, :status => 200
  end

  # to films and films_rating
  def delete_film()
    id = params[:id]
    res = send_req(@@url_film_rating_service, 'delete_film_rating', 'post', {:filmId => id})

    # todo vcheck 503 and 400
    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end

    res = send_req(@@url_film_service, 'delete_film', 'delete', id)

    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end

    return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
  end
end
