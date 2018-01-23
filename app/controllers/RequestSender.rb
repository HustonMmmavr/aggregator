class RequestSender
  @@server_not_avaliable = {:respMsg => "Server not fount", :status => 503}

  def response_to_hash(response)
    hash = JSON.load(response.body)
    p hash
    hash['status'] = response.code.to_i
    hash.keys.each do |key|
      hash[(key.to_sym rescue key) || key] = hash.delete(key)
    end
    p hash
    return hash
  end


  def send_post(path, params, headers = nil)
    p 'send_post'
    begin
      uri = URI::parse(path)
      req = Net::HTTP::Post.new(uri)

      if params != nil
        req.body = params.to_json
      end

      p headers
      if headers
        req[headers[:method]] = headers[:data]
      end

      req.content_type = "application/json"
      response =  Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
      return response_to_hash(response)
    rescue => err
      # p err
      # return @@server_not_avaliable
    end
  end

  def send_get(path, params = nil, query_params = nil, headers = nil)
    begin
      if params
        params.each do |param|
          path += "/" + param.to_s
        end
      end

      uri = URI::parse(path)
      request = Net::HTTP::Get.new(uri.request_uri)
      http = Net::HTTP.new(uri.host, uri.port).start

      p headers
      if headers
        request[headers[:method]] = headers[:data]
      end
      # if headers
      #   if headers[:token] != nil
      #     request['Authorization'] = "Token #{headers[:token]}"
      #   else
      #     request['Authorization'] = "Bearer #{headers[:appId]}:#{headers[:appSecret]}"
      #   end
      # end
      # if headers != nil
      #   req['Authorization'] = "Token #{headers[:token]}"
      # else
      #   p 'here'
      #   req['Authorization'] = "Bearer #{headers[:appId]}:#{headers[:appSecret]}"
      #

      if query_params != nil
        uri.query = URI::encode_www_form(query_params)
      end
      # p uri.query
      response = http.request(request)
      # Net::HTTP.get_response(uri)
      # p response
      return response_to_hash(response)
    rescue => err
      p err
      return @@server_not_avaliable
    end
  end

  def send_delete(path, params, headers = nil)
    begin
      uri = URI::parse(path + "/" + params.to_s)
      req = Net::HTTP::Delete.new(uri.path())
      if headers
        req['Authorization'] = "Bearer #{headers[:appId]}:#{headers[:appSecret]}"
      end
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
      return response_to_hash(response)
    rescue => err
      p err
      return @@server_not_avaliable
    end
  end
end
