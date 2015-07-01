require 'bunny'

module Traffiq
  class AMQP
    attr_reader :exchange

    def initialize(queue_url)
      @conn = Bunny.new(queue_url)
      @conn.start

      @channel = @conn.create_channel
    end

    # Checks if the connection to the Rabbit server is opened.
    def connected?
      @conn.connected? && @channel.open?
    end

    # Returns the exchanges that the channel has, except the default exchange.
    def exchanges
      @channel.exchanges
    end

    # Returns the queues that are binded on this connection.
    def queues
      @channel.queues
    end

    # Sets up the block to run when an error happens.
    #
    # @param [Block] block The block to run on uncaught exceptions.
    def on_uncaught_exception(&block)
      @channel.on_uncaught_exception(&block)
    end

    # Defines a *topic* exchange.
    #
    # This defines a durable topic exchange by default.
    #
    # @param [String] name The name of the exchange.
    # @param [Hash] options The options to define the exchange with.
    #
    # For options, look at Bunny's exchange options.
    #     http://rubybunny.info/articles/exchanges.html
    def define_exchange(name, options = {})
      options = {
        durable: true,
      }.merge(options)
      @exchange = @channel.topic(name, options)
    end

    # Binds a queue to the exchange and sets it's routing_key to `name`.
    #
    # @param [String] name The name of the queue and routing key to use.
    # @param [Hash] options Queue options.
    #
    # For options look at Bunny's Queue options.
    #     http://rubybunny.info/articles/queues.html
    def bind_queue(name, options = {})
      raise Traffiq::NoExchangeError.new if @exchange.nil?

      options = {
        durable: true,
        auto_delete: false,
      }.merge(options)

      @channel.queue(name, options)
              .bind(@exchange, routing_key: name)
    end

    # Subscribes to a specific routing_key. Executes the block when there's a
    # message routed there.
    #
    # A queue will be binded with the `routing_key` name.
    #
    # @param [String]  routing_key Routing key to subscribe to.
    # @param [Hash] options Subscribe options for the queue.
    # @param [Block] &block the block you want to execute when a message arrive.
    #
    # For options look at Bunny's Queue#subscribe options.
    #     http://rubybunny.info/articles/queues.html
    def subscribe(routing_key, options = {}, &block)
      q = bind_queue(routing_key)
      options = options.merge(manual_ack: true)

      q.subscribe(options) do |delivery_info, metadata, payload|
        block.call(delivery_info, metadata, payload)
        @channel.ack(delivery_info.delivery_tag)
      end
    end

    # Publishes a message to a specific routing key.
    #
    # @param [String] routing_key The routing key where you want to send the message to.
    # @param [Hash] payload What you want the message to have. It'll be converted to JSON.
    # @param [Hash] options Publish options
    #
    # @option opts [Boolean] :bind_to_queue If you want to bind a queue just in case there are no subscribers.
    def publish(routing_key, payload = {}, options = {})
      raise Traffiq::NoExchangeError.new if @exchange.nil?
      bind_queue(routing_key) if options[:bind_to_queue]
      @exchange.publish(MultiJson.dump(payload), routing_key: routing_key, persistent: true)
    end

    # Closes connection to the Rabbit server.
    def close
      @channel.close
      @conn.close
    end
  end
end
