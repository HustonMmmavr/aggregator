require_dependency "#{Rails.root.join('app', 'controllers', 'RequestSender.rb')}"

class DeleteJob
  include Sidekiq::Worker
  @@sender = RequestSender.new
  def perform(id)
    p 'init'
    fs = 'http://localhost:3005/delete_film'
    fr = 'http://localhost:8000/delete_film_rating'

    if (id != nil)
      res = @@sender.send_delete(fs, id)
      if res[:status] == 503
        Consumer.push('fs', id)
      end

      res = @@sender.send_post(fr, {:filmId => id})
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
        res = @@sender.send_delete(fs, id1)
        if res[:status] == 503
          Consumer.push('fs', id1)
        end
      end

      if data2 != nil
        id2 = data2[1]
        res = @@sender.send_post(fr, {:filmId=>id2})
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
