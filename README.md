# Traffiq

`Traffiq` helps you with your queues so you don't have to.

![Boston Traffic](http://statescoop.com/wp-content/uploads/2014/04/boston-traffic.jpg)

## Usage

For now only AMQP is supported with topic exchanges.

```ruby
  # consumer.rb
  amqp = Traffiq::AMQP.new(queue_url)
  amqp.define_exchange('events', durable: true)
  amqp.subscribe('routing_key', options) do |delivery_info, metadata, payload| 
    puts delivery_info, metadata, payload
  end

  # producer.rb
  amqp = Traffiq::AMQP.new(queue_url)
  amqp.define_exchange('events', durable: true)
  amqp.publish('routing_key', payload)
  amqp.close
```

By default, the exchanges created will be `durable`. Please note that the
producer and the consumer need to agree on the exchange options.

Queues will be created with `durable: true, auto_delete: false`.

## Test Helpers

`traffiq` comes with some test helpers for RabbitMQ integration tests. Notice
that when using these helpers you *must* have a RabbitMQ server running.

To use them, you can do the following:

```ruby
# test_helper.rb

require 'traffiq/test_helpers'
include Traffiq::TestHelpers

queue, amqp = setup_amqp_queue(server_url, exchange_name, routing_key)

amqp.publish(routing_key, { tony: 'montana' }.to_json)

last_amqp_queue_message(queue) # => { 'tony' => 'montana' }
```


## Installation

Add this line to your application's Gemfile:

```ruby
source 'user:password@gem.fury.io/ride'
gem 'traffiq'
```

And then execute:

    $ bundle

## Contributing

1. Fork it ( https://github.com/ride/traffiq/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
