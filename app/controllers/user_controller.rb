class UserController < ApplicationController
  # todo check for valid
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
    p @user.userPassword
    @err = Array.new()
    @user.check( @err)

    p @err
    # @@important_user_params.each do |key|
    #   if key == "userEmail"
    #     check = is_parameter_valid key, @user[key], @@email_regexp
    #   else
    #     check = is_parameter_valid key, @user[key], nil
    #   end
    #   if check != true
    #     @err.push(check)
    #   end
    # end
    if @err.size == 0
      p 'h'
      res = send_req(@@url_user_service, 'create_user', 'post', params[:user])
      if res[:status] == 503
        @err.push("Error with service. Please, try later!")
      else
        @err.push(res[:respMsg])
      end
    end

    if @err.size == 0
      #redirect "/"
    end

    return render "user/signup"

    # return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
  end

  # TODO check localy error and after check errors
  def signup_get()
    @err = Array.new()
    @user = User.new()
    return render "user/signup"
  end

  def get_user()
    check_user_id = is_parameter_valid 'id', id, @@int_regexp
    if check_user_id != true
      return render :json => {:respMsg => check_user_id}, :status => 400
    end
    # todo check if it id or nick and send
    id = params[:id]
    res = send_req(@@url_user_service, 'get_user_by_id', 'get',id)
    p res
    return render :json => {:respMsg => res[:respMsg], :data => res[:user]}, :status => res[:status]
  end
end
#
#
# end
#
# # if @user.errors.count == 0
# #   p @user
# # end
# #
# # res = send_req(@@url_user_service, 'create_user', 'post', params[:user])
# #
# # if res[:status] > 200
# #   if res[:status] == 409
# #     @err.push(res[:data])
# #   else
# #     p res[:data]
# #     @err.push(res[:data])
# #     # p "error"
# #     # @user.errors[:serverError] = "Error with server! Try later"
# #   end
# # end
# # render "films/films/1"
# end
#
# # def login()
# #   nick = params[:userName]
# #   pasw = params[:userPassword]
# # end
