require_dependency "#{Rails.root.join('app', 'controllers', 'RequestSender.rb')}"

class DeleteJob
  include Sidekiq::Worker
  @@sender = RequestSender.new
  def perform(id)
    p 'init'
    # $redis.flushdbs
    p Consumer.size
    p
    p id
    if (id != nil)
      res = @@sender.send_delete('http://localhost:3005/delete_film', id)
      p res
      if res[:status] == 503
        Consumer.push('fs', id)
      end
    end

    data = Consumer.pop('fs')
    while data != nil
      id = data[1]
      # p id
      # id= id[1]

      res = @@sender.send_delete('http://localhost:3005/delete_film', id)
      # p Consumer.size
      if res[:status] == 503
        Consumer.push('fs', id)
      end

      # p res

      sleep(1)

      data = Consumer.pop('fs')

      # id = Consumer.pop('fr')
      # res = send_req('localhost:3005', fr[:server_method], fr[:method], fr[:data])
      # if res[:status] == 503
      #   Consumer.push('fr', id)
      # end
    end
  end
end
