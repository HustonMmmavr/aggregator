class FilmController < ApplicationController

  # def func()
  #   p @@url_film_service
  #   render :json => {:messg => @@url_film_service}
  # end

  # todo check page
  def films()
    page = params[:page]
  end


  def film()
    id = params[:id]
  end

  def films_count()
    response = send_req(@@url_film_service, 'get', 'get_films_count')
    if (response.code != 200)

    end
    response.filmsCount
  end

  def delete_film()
    id = params[:id]
  end

  def update_film()
  end
end
