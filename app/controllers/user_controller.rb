class UserController < ApplicationController
  # todo check for valid

  @@hash_form = {:userName => "Name"}
  def signup()
    user = params[:user]
    @@important_user_params.each do |key|
        if key == "userEmail"
          check = is_parameter_valid key, user[key], @@email_regexp
        else
          check = is_parameter_valid key, user[key], nil
        end
        if check != true
          # logger.debug(key + "is invalid")
          return render :json => {:respMsg => check}, :status => 400
        end
      end
    res = send_req(@@url_user_service, 'create_user', 'post', params[:user])
    # render "user/signup"
    return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
  end


  def signup_post()
    @user = User.new params[:user]
    @err = Array.new()
    @user.check(@err)

    if @err.size == 0
      res = send_req(@@url_user_service, 'create_user', 'post', @user.to_hash)
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
      #redirect "/"
    end

    return render "user/signup"
  end

  def signup_get()
    @err = Array.new()
    @user = User.new()
    return render "user/signup"
  end


  def get_user_by_nick()
    nick = params[:nick]

    if nick == nil
      return render :json  => {:respMsg => "userName cant be empty"}, :status => 400
    end

    res = send_req(@@url_user_service, 'get_user_by_name', 'get',nick)
    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, status => res[:status]
    end

    render :json => {:user => res[:user]}, :status => res[:status]
  end

  def get_user_by_nick_ui()
    nick = params[:nick]
    if nick == nil

    end

    res = send_req(@@url_user_service, 'get_user_by_name', 'get', nick)
    if res[:status] != 200
      @message = res[:status].to_s + " " + res[:respMsg]
      render "user/user"
    end

    res = send_req(@@url_film_rating_service, 'get_linked_objects', 'get', userId,
    {:search_by => 'user_id'})
    if res[:status] != 200
      return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
    end

    film_ids = res[:filmId]

    res = send_req(@@url_user_service, 'get_user_by_id', 'get', userId)
    if res[:status] != 200
      user = "error with user service"
    else
      user = res[:user]
    end

    films = []
    film_ids.each do |id|
      res = send_req(@@url_film_service, 'get_film', 'get', id)
      if res[:status] < 500
        films.push(res[:film])
      end
    end

    return render :json => {:film => film, :users_rated_this_film => users}, :status => 200

  end

  def get_user()
    check_user_id = is_parameter_valid 'id', id, @@int_regexp
    if check_user_id != true
      return render :json => {:respMsg => check_user_id}, :status => 400
    end
    id = params[:id]
    res = send_req(@@url_user_service, 'get_user_by_id', 'get',id)
    p res
    return render :json => {:respMsg => res[:respMsg], :data => res[:user]}, :status => res[:status]
  end
end
