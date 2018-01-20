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

    p res

    if @err.size == 0
      return redirect_to film_get_url(:id => res[:data]) #{}"film/films_get"
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

    res = send_req(@@url_film_rating_service, 'get_linked_objects', 'get', @film['filmId'],
    {:search_by => 'film_id'})

    if res[:status] == 503
      @message = "Sorry, service error. Pleasy try later";
      return render "film/film", locals: {users: nil, message: @message}
    end

    user_ids = res[:userId]
    users = []
    if user_ids != nil
      user_ids.each do |id|
        p id
        res = send_req(@@url_user_service, 'get_user_by_id', 'get', id)
        p res
        if res[:status] < 500
          p res[:user]
          if res[:user] != nil
            users.push(res[:user])
          end
        else
          @message = "Sorry, service error. Pleasy try later";
          return render "film/film", locals: {users: nil, message: @message}
        end
      end
    end

    # p user/s

    render "film/film", locals: {users: users, message: nil}
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
