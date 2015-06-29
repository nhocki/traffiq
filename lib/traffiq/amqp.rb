require 'bunny'

module Traffiq
  class AMQP
    attr_reader :exchange

    def initialize(queue_url)
      @conn = Bunny.new(queue_url)
      @conn.start

      @channel = @conn.create_channel
    end

    def connected?
      @conn.connected? && @channel.open?
    end

    def exchanges
      @channel.exchanges
    end

    def on_uncaught_exception(&block)
      @channel.on_uncaught_exception(&block)
    end

    def define_exchange(exchange_name, options = {})
      options = {
        durable: true,
      }.merge(options)
      @exchange = @channel.topic(exchange_name, options)
    end

    def subscribe(routing_key, options = {}, &block)
      q = bind_queue(routing_key)
      options = options.merge(manual_ack: true)

      q.subscribe(options) do |delivery_info, metadata, payload|
        block.call(delivery_info, metadata, payload)
        @channel.ack(delivery_info.delivery_tag)
      end
    end

    def publish(routing_key, arguments = {})
      raise Traffiq::NoExchangeError.new if @exchange.nil?
      @exchange.publish(Oj.dump(arguments), routing_key: routing_key, persistent: true)
    end

    def close
      @channel.close
      @conn.close
    end

    private

    def bind_queue(routing_key, options = {})
      raise Traffiq::NoExchangeError.new if @exchange.nil?

      options = {
        durable: true,
        auto_delete: false,
      }.merge(options)

      @channel.queue(routing_key, options)
              .bind(@exchange, routing_key: routing_key)
    end
  end
end
