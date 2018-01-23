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

  # data -
  def get_oauth_token(*data)

  end

  def send_req(server_addr, server_method, method, params = nil, query_params = nil)
    path = 'http://' + server_addr + server_method
    p query_params
    if method == "get"
      if params != nil
        if !params.kind_of?(Array)
          arr = []
          arr.push params
          params = arr
        end
      end
      return @@sender.send_get(path, params, query_params)
    end
    if method == "post"
      p params
      return @@sender.send_post(path, params)
    end
    if method == "delete"
      return @@sender.send_delete(path, params)
    end
  end

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

  def update_token(server, old)
    p 'update_tok'
    p old
    headers = {method: 'Authorization', data: "Bearer #{@@appName}:#{@@appSecret}"}#{:appId => @@appName, :appSecret => @@appSecret}
    rec = ApplicationKey.where(:appName => @@appName).first
    if server == @@url_film_service
      res = @@sender.send_post('http://' + @@url_film_service  + "get_token", nil, headers)
      p res
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
    # p 'func'
    token = self.send func, server, old
    headers = {method: 'Authorization', data: "Token #{token}"}
    # headers = {:appId => @@appName, :appSecret => 'secret'}
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
        # p ne
        res =  @@sender.send_post(path, params, new_headers)
      end
      return res
    end
    if method == "delete"
      return @@sender.send_delete(path, params)
    end
  end

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


#
# def get_film_token()
#   rec = ApplicationKey.where(:appName => @@appName).first
#   p rec
#   if token = rec['keyForFilm'] == nil
#     token = 'epmty'
#   end
#   p 'token'
#   p token
#   return token
# end
#
# def get_rating_token()
#   rec = ApplicationKey.where(:appName => @@appName).first
#   token = rec[:keyForRating]
#   if token = rec['keyForFilm'] == nil
#     token = 'epmty'
#   end
#   return token
# end
#
# def get_user_token()
#   rec = ApplicationKey.where(:appName => @@appName).first
#   token = rec[:keyForUser]
#   p rec
#   if token = rec['keyForFilm'] == nil
#     token = 'epmty'
#   end
#   return token
# end


# def update_film_token()
#   p 'sefse;krfersjgjren'
#   p 'jkhj'
#   rec = ApplicationKey.where(:appName => @@appName).first
#   res = send_req(@@url_film_service, 'get_token', 'post', {:appId=> @@appName, :appSecret => rec['keyForFilm']})
#   # p 'sgergergr'
#   p res
#   p 'ggh'
#   token = res[:token]
#   rec = ApplicationKey.where(:appName => @@appName).first
#   rec.update(:keyForFilm => token)
#   return token
# end
#
# def update_rating_token()
#   res =send_req(@@url_film_rating_service, 'get_token', 'post', {:appId=> @@appName})
#   token = res[:token]
#   rec = ApplicationKey.where(:appName => @@appName).first
#   rec.update(:keyForRating => token)
#   return token
# end
#
# def update_user_token()
#   res =send_req(@@url_user_service, 'get_token', 'post', {:appId=> @@appName})
#   token = res[:token]
#   rec = ApplicationKey.where(:appName => @@appName).first
#   rec.update(:keyForUser => token)
#   return token
# end

# def update_film_token()
#   res =send_req(@@url_user_service, 'get_token', 'post', {:appId=> @@appName})
#   token = res[:token]
#   rec = ApplicationKey.where(:appName => @@appName).first
#   rec.update(:keyForFilm => token)
#   token
# end

# token = get_token(server_addr)
#{:appId => @@appName, :appSecret => token}
