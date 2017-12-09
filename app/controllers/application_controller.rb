require 'net/http'
require 'json'

class ApplicationController < ActionController::Base
  @@url_film_service = 'localhost:3000/'
  @@url_film_rating_service = 'localhost:8000/'
  @@url_user_service = 'localhost:3001/'

  def send_req(server_addr, server_method, method, params, query_params = nil)
    begin
      url_str = 'http://' + server_addr + '/' + server_method
      if method == "post"
        uri = URI::parse(url_str)
        req = Net::HTTP::Post.new(uri)
        req.body = params.to_json
        req.content_type = "application/json"
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
        response = Net::HTTP.get_response(uri)
      end
      if method == "delete"
        uri = URI::parse(url_str + "/" + params.to_s)
        req = Net::HTTP::Delete.new(uri.path())
        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end
      end
      hash = JSON.load(response.body)
      hash['code'] = response.code
      return hash
    rescue => err
      return {:respMsg => "Server not fount", :status => 503}
    end
  end
end

# url = URI.parse(server_addr + server_method)
# req = Net::HTTP::Get.new(url.to_s)

# New::Http::Post.new()

# http = Net::HTTP.new(url.host, url.port)
# http.use_ssl = (url.scheme == "https")
# request = Net::HTTP::Get.new(url.to_s)
# http = Net::HTTP.new(url.host, url.port)
# response = http.request(request)


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
