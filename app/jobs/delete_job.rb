require_dependency "#{Rails.root.join('app', 'controllers', 'RequestSender.rb')}"

class DeleteJob
  include Sidekiq::Worker
  @@sender = RequestSender.new
  @@url_film_service = 'http://localhost:3005/'
  @@url_film_rating_service = 'http://localhost:8000/'
  # @@headers = {:appId => 'aggregator', :appSecret => 'secret'}
  @@headers = {method: 'Authorization', data: "Bearer aggregator:secret"}

  # def update_token(server)
  #   # p 'update_tok'
  #   p old
  #   headers = {method: 'Authorization', data: "Bearer #{@@appName}:#{@@appSecret}"}#{:appId => @@appName, :appSecret => @@appSecret}
  #   rec = ApplicationKey.where(:appName => @@appName).first
  #   if server == @@url_film_service
  #     res = @@sender.send_post('http://' + @@url_film_service  + "get_token", nil, headers)
  #     p res
  #     token = res[:token]
  #     rec.update(:keyForFilm => token)
  #   end
  #   if server ==
  #     res = @@sender.send_post('http://' + @@url_film_rating_service  + "get_token", nil,  headers)
  #     token = res[:token]
  #     rec.update(:keyForRating => token)
  #   end
  #   return token
  # end
  #
  # def check_status(resp)
  #   if resp[:status] == 401
  #
  # end

  def delete_film(fs, id)
    p '---------------------------------------------------'
    p ApplicationKey.where(:appName => 'aggregator')
    p '-------------------------------------------------'
    p ''
    rec = ApplicationKey.where(:appName=>'aggregator').first
    token_headers = {method: "Authorization", :data => "Token #{rec['keyForFilm']}"}
    res = @@sender.send_delete(fs, id, token_headers)
    p res
    if res[:status] == 401
      res = @@sender.send_post(@@url_film_service  + "get_token", nil,@@headers)
      p res
      token_headers[:data] = res[:token]
      rec.update(:keyForFilm => res[:token])
      res = @@sender.send_delete(fs, id, token_headers)
    end
    return res
  end

  def delete_rating(fr, id)
    p "rat"
    # p '---------------------------------------------------'
    # p ApplicationKey.where(:appName => 'aggregator')
    p '-------------------------------------------------'
    rec = ApplicationKey.where(:appName=>'aggregator').first
    p rec['keyForRating']
    p rec
    token_headers = {method: "Authorization", :data => "Token #{rec['keyForRating']}"}

    # token_headers = {:token => ApplicationKey.where(:appName=>'aggregator').first['keyForRating']}
    res = @@sender.send_post(fr, {:filmId => id}, token_headers)
    if res[:status] == 401
      res = @@sender.send_post(@@url_film_rating_service  + "get_token", nil,  @@headers)
      token_headers[:data] = res[:token]
      rec.update(:keyForRating => rec[:token])
      res = @@sender.send_post(fr, {:filmId => id}, token_headers)
    end
    return res
  end

  def perform(id)
    p 'init'
    fs = @@url_film_service + 'delete_film'
    fr = @@url_film_rating_service + 'delete_film_rating'

    # headers = {:appId => 'aggregator', :appSecret => 'secret'}
    # token_film = ApplicationKey.where(:appName=>'aggregator').first.keyForFilm
    # token_rating = ApplicationKey.where(:appName =>
      # 'aggregator').fist.keyForRating
    if (id != nil)
      res = delete_film(fs, id)
      # res = @@sender.send_delete(fs, id)
      # check_status(res, @@url_film_service)

      if res[:status] == 503
        Consumer.push('fs', id)
      end


      res = delete_rating(fr, id)
      # res = @@sender.send_post(fr, {:filmId => id})
      if res[:status] == 503
        Consumer.push('fr', id)
      end
    end

    data1 = Consumer.pop('fs')
    data2 = Consumer.pop('fr')
    while data1 != nil || data2 != nil
      p 'a'
      p data1
      p data2
      if data1 != nil
        id1 = data1[1]
        res = delete_film(fs,id1)
        # res = @@sender.send_delete(fs, id1)

        if res[:status] == 503
          Consumer.push('fs', id1)
        end
      end

      if data2 != nil
        id2 = data2[1]
        res = delete_rating(fr, id2)
        # res = @@sender.send_post(fr, {:filmId=>id2})
        if res[:status] == 503
          Consumer.push('fr', id2)
        end
      end
      sleep(10)

      data1 = Consumer.pop('fs')
      data2 = Consumer.pop('fr')
    end
  end
end
