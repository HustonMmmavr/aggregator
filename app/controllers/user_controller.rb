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
    id = params[:id]
    res = send_req(@@url_user_service, 'get_user_by_id', 'get',
      [id])
    p res
    return render :json => {:respMsg => res[:respMsg], :data => res[:user]}, :status => res[:status]
       # if id == nil
  end

  # def get_user_by_nick

  # end

end
