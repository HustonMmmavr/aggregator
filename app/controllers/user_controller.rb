class UserController < ApplicationController
  # todo check for valid
  def signup()
    p params
    res = send_req(@@url_user_service, 'create_user', 'post',
      params[:user])
    return render :json => {:respMsg => res[:respMsg]}, :status => res[:status]
  end

  def login()
    nick = params[:userName]
    pasw = params[:userPassword]
  end

  def get_user()
    # todo check if it id or nick and send
    id = params[:id]
    res = send_req(@@url_user_service, 'get_user_by_id', 'get',
      [id])
    p res
    return render :json => {:respMsg => res[:respMsg], :data => res[:user]}, :status => res[:status]
  end


end
