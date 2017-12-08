class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  @@url_film_service = 'localhost:3000/'
  @@url_film_rating_service = 'localhost:8000/'
  @@url_user_service = 'localhost:3001/'

  # def fill_req(method, req, params, query_params)
  #   if method == "post"
  #     uri = URI.parse(url_str + params)
  #     request = Net::HTTP::Get.new(url.to_s)
  #     http = Net::HTTP.new(url.host, url.port)
  #     response = http.request(request)
  #   end
  #   if method == "get"
  #     url = URI.parse(url_str + params)
  #     request = Net::HTTP::Get.new(url.to_s)
  #     http = Net::HTTP.new(url.host, url.port)
  #     response = http.request(request)
  #   end
  #   if method == "delete"
  #     response = nil
  #   end
  # end
  require 'net/http'
  require 'json'
  def send_req(server_addr, server_method, method, params, query_params = nil)
    begin
      url_str = 'http://' + server_addr + '/' + server_method
      p url_str
      p method
      if method == "post"
        uri = URI::parse(url_str)
        req = Net::HTTP::Post.new(uri)
        req.body = params.to_json
        req.content_type = "application/json"
        p req
        response =  Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end
      end
      if method == "get"
        url_str += "/" + params.to_s
        uri = URI::parse(url_str)
        if query_params != nil
          uri.query = URI::encode_www_form(query_params)
        end
        p uri
        response = Net::HTTP.get_response(uri)
      end
      if method == "delete"
        uri = URI::parse(url_str + "/" + params.to_s)
        p uri
        response = Net::HTTP.get_response(uri)
      end

      # if response.header['Content-type'] == 'application/json'
        hash = JSON.load(response.body)
        hash['code'] = response.code
        return hash
      # else
      #   if response == Net::HTTPNotFound
      #     return {:respMsg => 'Method not allowed', :status => 500}
      #   end
      # end
    rescue => err
      return {:respMsg => "Server not fount", :status => 503}
    end
  end

  # send_req('localhost:3000', 'get_films')
  res = send_req('localhost:3000', 'add_film', 'post', {:filmName => 'name',
                             :filmAbout => 'efe',                           :filmTitle => 'title', :filmDirector => 'dir',
  :filmYear=>'12', :filmLength => '12'}, )
  p res
  res = send_req('localhost:3000', 'get_film', 'get', 3)
  p res
  res = send_req('localhost:3000', 'delete_film', 'delete', 3)
  p res
end

# url = URI.parse(server_addr + server_method)
# req = Net::HTTP::Get.new(url.to_s)

# New::Http::Post.new()

# http = Net::HTTP.new(url.host, url.port)
# http.use_ssl = (url.scheme == "https")
# request = Net::HTTP::Get.new(url.to_s)
# http = Net::HTTP.new(url.host, url.port)
# response = http.request(request)
