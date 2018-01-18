# require_dependency "#{Rails.root.join('app', 'services', 'publisher.rb')}"

class FilmController < ApplicationController
  @@films_on_page = 7

  def films()
    if params[:count] == nil
      params[:count] = @@films_on_page.to_s
    end

    arr = ['page', 'count']
    arr.each do |key|
      check = is_parameter_valid key, params[key], @@int_regexp
      if check != true
        return render :json => {:respMsg => check}, :status => 400
      end
    end
    p params

    page = Integer(params[:page])
    count_on_page = Integer(params[:count])

    res = send_req(@@url_film_service, 'get_films', 'get', [page * count_on_page, count_on_page])

    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end

    render :json => {:respMsg => "Ok", :data => res[:films]}, :status => 200
  end

  def paginate(current, offset = 2)
    res = send_req(@@url_film_service, 'get_films_count', 'get')
    # if res[:status] != 200
      # return render m:json => {:respMsg => res[:respMsg]}, :status => res[:status]
    # end
    p @count_on_page
    count = res[:filmsCount]
    pages, r = count.divmod(@count_on_page)
    pages +=  (@count_on_page > r * 2 ? 0 : 1)

    start_ = current - offset > 0 ? pages - offset : 1
    end_  = current + offset > pages ? pages : current + offset

    return pages, start_, end_
  end

  def films_get()
    if params[:page] == nil || params[:page] == ""
      params[:page] = "1"
    end

    if params[:count] == nil
      params[:count] = @@films_on_page.to_s
    end


    arr = ['page', 'count']
    arr.each do |key|
      check = is_parameter_valid key, params[key], @@int_regexp
      if check != true
        return render "errors/error", locals: {message: check}#:json => {:respMsg => res[:respMsg]}
      end
    end

    page = Integer(params[:page])
    count_on_page = Integer(params[:count])
    @count_on_page = count_on_page
    res = send_req(@@url_film_service, 'get_films', 'get', [page * count_on_page, count_on_page])
    if res[:status] != 200
      return render "errors/error", locals: {message: "#{res[:status]} #{res[:respMsg]}"}#:json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end

    @films = res[:films]
    pages, start_, end_ = paginate(page)

    render "film/films_get", locals: {st: start_, en: end_, cur: page, :pages => pages, con: "film", act: "films_get"}#, locals: {films: films_arr}#res[:films]}#:json => {:respMsg => "Ok", :data => res[:films]}, :status => 200
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


  def add_film_post()
    @film = Film.new params[:film]
    @err = @film.check()
    p @film.filmImage

    if @err.size == 0
      res = send_req(@@url_film_service, 'add_film', 'post', @film.to_hash)
      if res[:status] < 300
        image = @film.filmImage
        if image != nil
          File.open(Rails.root.join('app', 'assets', 'images', 'films',
              image.original_filename), "wb") do |file|
            file.write(image.read)
          end
        end
      else
        if res[:status] == 503
          @err.push("Error with service. Please, try later!")
        else
          @err.push(res[:respMsg] + " " + res[:status].to_s)
        end
      end
    end

    if @err.size == 0
      #redirect "/"
    end

    return render "film/create_film"
  end


  def add_film_get()
    @film = Film.new
    @err = Array.new
    render "film/create_film"
  end

  def film_get()
    id = params[:id]
    check_film_id = is_parameter_valid 'id', id, @@int_regexp
    if check_film_id != true
      return render "errors/error", locals: {message: check_film_id}#:json => {:respMsg => check_film_id}, :status => 400
    end


    res = send_req(@@url_film_service, 'get_film', 'get', id)
    if res[:status] != 200
      return render "errors/error", locals: {message: "#{res[:status]} #{res[:respMsg]}"}
    end

    @film = res[:film]

    render "film/film"
  end

  def film()
    id = params[:id]

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


  def delete_film()
    id = params[:id]

    check_film_id = is_parameter_valid 'id', id, @@int_regexp
    if check_film_id != true
      return render :json => {:respMsg => check_film_id}, :status => 400
    end

    DeleteJob.perform_async(id)
    return render :json => {:respMsg => "Ok"}, :status => 200
  end
end


#
# def delete_film()
#   id = params[:id]
#
#   #TODO check params
#   check_film_id = is_parameter_valid 'id', id, @@int_regexp
#   if check_film_id != true
#     return render :json => {:respMsg => check_film_id}, :status => 400
#   end
#
#   # fr = {:host => @@url_film_rating_service, :server_method => 'delete_film_rating',
#       # :method => 'post', :data => {:filmId => id})
#
#   # fs = {:host => @@url_film_service, :server_method => 'delete_film',
#     # :method => 'delete', :data => {:id=> id})}
#
#   DeleteJob.perform_async(id)
#
#   # Consumer.push('fs', id)
#   # Consumer.push('fr', id)
#   # DeleteJob.delete('fr', host, @@url_film_rating_service, 'delete_film_rating', 'post', {:filmId => id})
#   # DeleteJob.delete ('fs', @@url_film_service, 'delete_film', 'delete', {:id=> id})
#   # params_to_fr = {:filmId => id}
#   # res = send_req(@@url_film_rating_service, 'delete_film_rating', 'post', {:filmId => id})
#   #
#   # if res[:status] == 503
#   #   p 'a'
#   #   ProducerJob.publish("fr", params_to_fr)
#   #   #return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
#   # end
#   #
#   #
#   # params_to_fs = {:id => id}
#   # res = send_req(@@url_film_service, 'delete_film', 'delete', id)
#   # if res[:status] == 503
#   #   ProducerJob.publish("fs", params_to_fs)
#   #   # return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
#   # end
#
#   return render :json => {:respMsg => "Ok"}, :status => 200
#   # return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
# end

# films_arr = Array.new
# res[:films].each do |data|
#   p data
#   f = Film.new(data)
#   films_arr.push(f)
# end

# @films = res[:films]
# p @films


# films_arr = Array.new
# res[:films].each do |data|
#   p data
#   f = Film.new(data)
#   films_arr.push(f)
# end

# @films = res[:films]
# p @films
