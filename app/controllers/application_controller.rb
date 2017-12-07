class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  @@url_film_service = 'localhost:3000/'
  @@url_film_rating_service = 'localhost:8000/'
  @@url_user_service = 'localhost:3001/'

  def send_req(server_addr, server_method,  method, params)
    begin
      url_str = server_addr + server_method
      if method == "post"
        url = URI.parse(url_str + params)
        request = Net::HTTP::Get.new(url.to_s)
        http = Net::HTTP.new(url.host, url.port)
        response = http.request(request)
      end
      if method == "get"

      end
      if method == "delete"
        response = nil
      end
      hash = JOSN.loads(response)
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
