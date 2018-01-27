require 'net/http'
require 'json'
require 'RequestSender.rb'

class ApplicationController < ActionController::Base
  @@url_film_service = 'localhost:3005/'
  @@url_film_rating_service = 'localhost:8000/'
  @@url_user_service = 'localhost:3000/'

  @@important_film_params = ['filmTitle', 'filmAbout', 'filmLength', 'filmYear', 'filmDirector']
  @@all_film_params = ['filmTitle', 'filmAbout', 'filmLength', 'filmYear', 'filmDirector',
                'filmImage', 'filmRating']

  @@important_user_params = ['userName', 'userEmail', 'userPassword']

  @@sender = RequestSender.new()
  @@int_regexp = /\A[-+]?[0-9]+\z/
  @@rating_regexp = /^[+-]?([1-9]\d*|0)(\.\d+)?$/
  @@email_regexp = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  @@appName = 'aggregator'
  @@page = "1"
  @@appSecret = 'secret'

  ##########################################################
  ############## oauth
  #########################################################

  def check_token_valid(cookies)
    p 'check_token'
    p cookies['access_token']
    res = send_req_with_auth(@@url_user_service, 'check_token', 'post', {:access_token => cookies['access_token']})
    p res
    if res[:status] == 401
      p 'update'
      res = send_req_with_auth(@@url_user_service, 'update_tokens', 'post', {:refresh_token => cookies['refresh_token']})
      cookies[:access_token] = res[:tokens]['access_token']
      cookies[:refresh_token] = res[:tokens]['refresh_token']
    end

  end

  # its fucking crutch
  def login_user(request, params, cookies)
    code = params['code']
    auth = cookies[:access_token]

    if auth
      check_token_valid(cookies)
      return {:tokens => {:access_token => cookies[:access_token],
                          :refresh_token => cookies[:refresh_token]}}
    end

    if code
      code = params['code']
      res = send_req_with_auth(@@url_user_service, 'get_oauth_tokens', 'post', {:code => code})
      if res[:status] != 200
        return res
      end
      cookies['access_token'] = res[:tokens]["access_token"]
      cookies['refresh_token'] = res[:tokens]["refresh_token"]
    end

    # request to get code
    if code == nil && auth == nil
      url = request.original_url.sub('localhost', '0.0.0.0')
      oauth_server = @@url_user_service.sub('localhost', '0.0.0.0')
      return {:url => "http://#{oauth_server}/login?client_id=" +
                      "#{@@appName}&client_secret=#{@@appSecret}" +
                      "&redirect_url=#{url}&response_type=code"}
    end

    return res
  end

  def login_user_ui()

  end


##########################################################################
####################3 old ################################################
##########################################################################
  # def send_req(server_addr, server_method, method, params = nil, query_params = nil)
  #   path = 'http://' + server_addr + server_method
  #   p query_params
  #   if method == "get"
  #     if params != nil
  #       if !params.kind_of?(Array)
  #         arr = []
  #         arr.push params
  #         params = arr
  #       end
  #     end
  #     return @@sender.send_get(path, params, query_params)
  #   end
  #   if method == "post"
  #     p params
  #     return @@sender.send_post(path, params)
  #   end
  #   if method == "delete"
  #     return @@sender.send_delete(path, params)
  #   end
  # end
  #
  def get_token(server, data = nil)
    rec = ApplicationKey.where(:appName => @@appName).first
    if server == @@url_user_service
      token = rec['keyForUser']#get_user_token
    end
    if server == @@url_film_service
      token = rec['keyForFilm']#get_film_token
    end
    if server == @@url_film_rating_service
      token = rec['keyForRating']#get_rating_token
    end
    return token
  end

  ##############################################################
  ##################### service #######################
  ##################################################

  def update_token(server, old)
    # p 'update_tok'
    # p old
    headers = {method: 'Authorization', data: "Bearer #{@@appName}:#{@@appSecret}"}#{:appId => @@appName, :appSecret => @@appSecret}
    rec = ApplicationKey.where(:appName => @@appName).first
    if server == @@url_film_service
      res = @@sender.send_post('http://' + @@url_film_service  + "get_token", nil, headers)
      # p res
      token = res[:token]
      rec.update(:keyForFilm => token)
    end
    if server == @@url_user_service
      res = @@sender.send_post('http://' + @@url_user_service  + "get_token", nil, headers)
      token = res[:token]
      rec.update(:keyForUser => token)
    end
    if server == @@url_film_rating_service
      res = @@sender.send_post('http://' + @@url_film_rating_service  + "get_token", nil,  headers)
      token = res[:token]
      rec.update(:keyForRating => token)
    end
    return token
  end

  def get_headers(server, func, old = nil)
    token = self.send func, server, old
    headers = {method: 'Authorization', data: "Token #{token}"}
    return headers
  end

  def send_req_with_auth(server_addr, server_method, method, params = nil, query_params = nil)
    path = 'http://' + server_addr + server_method
    headers = get_headers(server_addr, :get_token)

    p headers
    if method == "get"
      if params != nil
        if !params.kind_of?(Array)
          arr = []
          arr.push params
          params = arr
        end
      end

      res = @@sender.send_get(path, params, query_params, headers)
      if res[:status] == 401
        new_headers = get_headers(server_addr, :update_token, headers)
        p headers
        res = @@sender.send_get(path, params, query_params, new_headers)
      end
      return res
    end
    if method == "post"
      res =  @@sender.send_post(path, params, headers)
      if res[:status] == 401
        new_headers = get_headers(server_addr, :update_token, headers)
        res =  @@sender.send_post(path, params, new_headers)
      end
      return res
    end
    if method == "delete"
      return @@sender.send_delete(path, params, headers)
      if res[:status] == 401
        new_headers = get_headers(server_addr, :update_token, headers)
        res =  @@sender.send_delete(path, params, headers)
      end
      return res
    end
  end

  ############################################################
  ########################## func ######################
  #####################################################

  def is_parameter_valid(param_name, param, regexp)
    if param == nil || param == ""
        return param_name + " is Empty"
    end
    if regexp
        if !regexp.match? param
            return param_name + " is invalid"
        end
    end
    true
  end
end
