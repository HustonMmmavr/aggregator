class ProducerJob < ApplicationJob
  @@queue_name = 'aggregator'
  p 'started'
  # In order to publish message we need a exchange name.
  # Note that RabbitMQ does not care about the payload -
  # we will be using JSON-encoded strings
  def self.publish(exchange, message = {})
    # grab the fanout exchange
    p 'im publishe'
    x = channel.fanout("#{@@queue_name}.#{exchange}")
    # and simply publish message
    x.publish(JSON.dump(message))
  end

  def self.channel
    @channel ||= connection.create_channel
  end

  # We are using default settings here
  # The `Bunny.new(...)` is a place to
  # put any specific RabbitMQ settings
  # like host or port
  def self.connection
    @connection ||= Bunny.new.tap do |c|
      c.start
    end
  end
end
