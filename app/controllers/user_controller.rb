class UserController < ApplicationController
##############################################

  def login()
    p request.original_url
   return redirect_to  'http://0.0.0.0:3000/login?redirect_url=http://0.0.0.0:7000/'
  end

  def login_get()
    @user = User.new
    @err = Array.new
    render "user/signin"
  end

  def login_post()
    @user = User.new(params[:user])
    @err = Array.new
    p @user.to_hash

    res = send_req_with_auth(@@url_user_service, 'login_ui', 'post', @user.to_hash)
    p res

    if res[:status] != 200
      if res[:status] == 503
        @err.push("Error with service. Please, try later!")
      else
        @err.push(res[:respMsg] + " " + res[:status].to_s)
      end
    end

    if @err.count > 0
      return render "user/signin"
    end

    cookies['access_token'] = res[:tokens]['access_token']
    cookies['refresh_token'] = res[:tokens]['refresh_token']
    redirect_to '/'
  end

  ###################################################################

  def signup()
    user = params[:user]
    @@important_user_params.each do |key|
        if key == "userEmail"
          check = is_parameter_valid key, user[key], @@email_regexp
        else
          check = is_parameter_valid key, user[key], nil
        end
        if check != true
          return render :json => {:respMsg => check}, :status => 400
        end
    end

    res = send_req_with_auth(@@url_user_service, 'create_user', 'post', params[:user])
    return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
  end


  def signup_post()
    @user = User.new params[:user]
    @err = Array.new()
    @user.check(@err)

    if @err.size == 0
      res = send_req_with_auth(@@url_user_service, 'create_user', 'post', @user.to_hash)
      if res[:status] < 300
        image = @user.userImage
        if image != nil
          File.open(Rails.root.join('app', 'assets', 'images', image.original_filename), "wb") do |file|
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
      return redirect_to "/"
    end

    return render "user/signup"
  end

  def signup_get()
    @err = Array.new()
    @user = User.new()
    return render "user/signup"
  end


  def get_user_by_nick()
    res = login_user(request, params, cookies)
    #.original_url)
    # p cookies['access_token']
    if res != nil
      if res[:url]
        return redirect_to res[:url]
      end
    end

    nick = params[:nick]

    if nick == nil
      return render :json  => {:respMsg => "userName cant be empty"}, :status => 400
    end

    res = send_req_with_auth(@@url_user_service, 'get_user_by_name', 'get',nick)
    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, status => res[:status]
    end

    return render :json => {:user => res[:user]}, :status => res[:status]
  end

  def get_user_by_nick_ui()
    nick = params[:nick]
    if nick == nil

    end

    res = send_req_with_auth(@@url_user_service, 'get_user_by_name', 'get', nick)
    if res[:status] != 200
      return render "errors/error", locals: {message: "#{res[:status]} #{res[:respMsg]}"}
    end

    user = res[:user]
    res = send_req_with_auth(@@url_film_rating_service, 'get_linked_objects', 'get', user["userId"],
    {:search_by => 'user_id'})
    if res[:status] != 200
      return render "errors/error", locals: {message: "#{res[:status]} #{res[:respMsg]}"}
    end

    film_ids = res[:filmId]

    films = []
    film_ids.each do |id|
      res = send_req_with_auth(@@url_film_service, 'get_film', 'get', id)
      if res[:status] < 500
        if res[:film] != nil
          films.push(res[:film])
        end
      else
        return render "user/user", locals: {films: nil, message: "#{res[:status]} #{res[:respMsg]}"}
      end
    end

    render "user/user", locals: {user: user, films: films, message: nil}
  end

  def get_user()
    p cookies[:access_token]
    id = params[:id]
    check_user_id = is_parameter_valid 'id', id, @@int_regexp
    if check_user_id != true
      return render :json => {:respMsg => check_user_id}, :status => 400
    end
    id = params[:id]
    res = send_req_with_auth(@@url_user_service, 'get_user_by_id', 'get',id)
    p res
    return render :json => {:respMsg => res[:respMsg], :data => res[:user]}, :status => res[:status]
  end
end
