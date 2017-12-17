class UserController < ApplicationController
  # todo check for valid
  def signup()
    @@important_params.each do |key|
        if key == "userEmail"
          check = is_parameter_valid key, params[key], @@email_regexp
        else
          check = is_parameter_valid key, params[key]
        end
        if check != true
          # logger.debug(key + "is invalid")
          return render :json => {:respMsg => check}, :status => 400
        end
      end
    res = send_req(@@url_user_service, 'create_user', 'post', params[:user])
    return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
  end

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
