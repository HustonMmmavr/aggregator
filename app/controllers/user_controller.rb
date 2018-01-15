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


  # def signup_ui()
  #   user = params[:user]
  #   @@important_user_params.each do |key|
  #       if key == "userEmail"
  #         check = is_parameter_valid key, user[key], @@email_regexp
  #       else
  #         check = is_parameter_valid key, user[key], nil
  #       end
  #       if check != true
  #         # logger.debug(key + "is invalid")
  #         return render :json => {:respMsg => check}, :status => 400
  #       end
  #     end
  #   # render "user/signup"
  #   return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
  # end

  def signup_get()
    @err = Array.new()
    @user = User.new
    p @err
    render "user/signup"
  end

  def signup_post()
    @user = User.new(params["user"])
    @err = Array.new()

    @@important_user_params.each do |key|
      if key == "userEmail"
        check = is_parameter_valid key, @user[key], @@email_regexp
      else
        check = is_parameter_valid key, @user[key], nil
      end
      if check != true
        @err.push(check)
      end
    end

    p @err
    if @err.count == 0
      res = send_req(@@url_user_service, 'create_user', 'post', @user)#params[:user])
      if res[:status] > 220
        @err.push( res[:data])
      end
    end
    if @err.count == 0
    #return render "films/films/1"
    end
    redirect_to signup_url(@user)

  end



  # TODO check localy error and after check errors
#   def signup_ui()
#
#     if request.method == "GET"
#       @err = Array.new()
#       @user = User.new
#     else
#       user = params[:user]
#       @@important_user_params.each do |key|
#         if key == "userEmail"
#           check = is_parameter_valid key, user[key], @@email_regexp
#         else
#           check = is_parameter_valid key, user[key], nil
#         end
#         if check != true
#           @err.push(check)
#         end
#       end
#       res = send_req(@@url_user_service, 'create_user', 'post', params[:user])
#       if res[:status] > 220
#         @err.push(res[:ststus].to_s + " " + res[:data])
#       end
#       if @err.count == 0
#       # return render "films/films/1"
#       end
#     end
#
#
#     return render "user/signup"
#     # if @err == nil
#     #   @err = Array.new()
#     # end
#     #
#     # if @user == nil
#     #   @user = User.new
#     # end
#     #
#     # if @user.check() == false
#     #   return render "user/signup"
#     # end
#
#
#
#
#     # if @user.errors.count == 0
#     #   p @user
#     # end
#     #
#     # res = send_req(@@url_user_service, 'create_user', 'post', params[:user])
#     #
#     # if res[:status] > 200
#     #   if res[:status] == 409
#     #     @err.push(res[:data])
#     #   else
#     #     p res[:data]
#     #     @err.push(res[:data])
#     #     # p "error"
#     #     # @user.errors[:serverError] = "Error with server! Try later"
#     #   end
#       # return render "user/signup"
#     # end
#     # render "films/films/1"
# end

  # def login()
  #   nick = params[:userName]
  #   pasw = params[:userPassword]
  # end

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
