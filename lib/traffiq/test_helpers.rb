module Traffiq
  module TestHelpers
    def setup_amqp_queue(url, exchange_name, routing_key)
      amqp = Traffiq::AMQP.new(url)
      amqp.define_exchange(exchange_name)
      queue = amqp.queues[routing_key]
      queue.purge
      return queue, amqp
    end

    def last_amqp_queue_message(queue)
      _, _, payload = queue.pop
      if payload
        payload = JSON.parse(payload)
      end
      payload
    end
  end
end
