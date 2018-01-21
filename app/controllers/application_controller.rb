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

  @@page = "1"

  # data -
  def get_oauth_token(*data)

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

  def send_req(server_addr, server_method, method, params = nil, query_params = nil)
    path = 'http://' + server_addr + server_method
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
      return @@sender.send_post(path, params)
    end
    if method == "delete"
      return @@sender.send_delete(path, params)
    end
  end
end
