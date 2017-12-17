require_dependency "#{Rails.root.join('app', 'services', 'publisher.rb')}"

class FilmController < ApplicationController
  @@films_on_page = 7
  def films()
    page = Integer(params[:page])
    count_on_page = params[:count]
    arr = ['page', 'count']

    if count_on_page = nil
      count_on_page = @@films_on_page
    end


    arr.each do |key|
      check = is_parameter_valid, key, params[key], @@int_regexp
      if check != true
        return render :json => {:respMsg => check}, :status => 400
      end
    end

    res = send_req(@@url_film_service, 'get_films', 'get', [page * count_on_page, count_on_page])

    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end

    render :json => {:respMsg => "Ok", :data => res[:films]}, :status => 200
  end

  def add_film()
    @@important_film_params.each do |key|
      if key == 'filmLength' || key == 'filmYear'
        check = is_parameter_valid key, params[key], @@int_regexp
      else
        check = is_parameter_valid key, params[key], nil
      end
      if check != true
        return render :json => {:respMsg => check}, :status => 400
      end
    end

    res = send_req(@@url_film_service, 'add_film', 'post', params[:film])
    if res[:status] > 300
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end

    render :json => {:respMsg => res[:respMsg], :data => res[:data]}, :status => res[:status]
  end

  def film()
    id = params[:id]

    #TODO check params
    check_film_id = is_parameter_valid 'id', id, @@int_regexp
    if check_film_id != true
      return render :json => {:respMsg => check_film_id}, :status => 400
    end

    res = send_req(@@url_film_service, 'get_film', 'get', id)
    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end
    render :json => {:respMsg => "Ok", :data => res[:film]}, :status => 200
  end

  def get_films_count()
    res = send_req(@@url_film_service, 'get_films_count', 'get')
    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end
    @films_count = res[:filmsCount]
    render :json => {:respMsg => "Ok",:filmsCount => @films_count}, :status => 200
  end

  # to films and films_rating
  def delete_film()
    id = params[:id]

    #TODO check params
    check_film_id = is_parameter_valid 'id', id, @@int_regexp
    if check_film_id != true
      return render :json => {:respMsg => check_film_id}, :status => 400
    end

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
