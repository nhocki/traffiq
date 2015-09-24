# Traffiq

[![Circle CI](https://circleci.com/gh/ride/traffiq.svg?style=svg)](https://circleci.com/gh/ride/traffiq)

`Traffiq` helps you with your queues so you don't have to.

![Boston Traffic](http://statescoop.com/wp-content/uploads/2014/04/boston-traffic.jpg)

## Usage

For now only AMQP is supported with *topic* exchanges.

```ruby
  # consumer.rb
  amqp = Traffiq::AMQP.new("user:password@rabbit-server.com")
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

More documentation can be found in the code as inline comments.

### Publishing Messages

Be aware that, by design, `topic` exchanges will drop any message sent to a
queue that has never been binded to. So you will need to make sure your
consumers start before the producer (and bind to a specific queue) before you
send messages to them.

You can force the publisher to bind to a queue with the `bind_to_queue`
option on the `#publish` method. This will create a queue with the same name of
the routing key, so be careful with that. You don't want to have many durable
queues created by temporary proccesses.

```ruby
amqp = Traffiq::AMQP.new("server")
amqp.publish('routing_key', payload)
amqp.queues['routing_key'] # => nil

amqp.publish('routing_key', payload, bind_to_queue: true)
amqp.queues['routing_key'] # => Bunny::Queue
```

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
gem 'traffiq'
```

And then execute:

    $ bundle

## Running Tests

Traffiq requires RabbitMQ to be running for tests. So after you start your
rabbit server, you can test with Rake:

```
bundle exec rake test
```

You can pass the Rabbit URL via the `QUEUE_URL` environment variable. If you are
running Rabbit with the default configuration you don't need this. Same goes for
Boxen, Traffiq will detect if you have Boxen installed and use the Boxen default
port (55672).

## Contributing

1. Fork it ( https://github.com/ride/traffiq/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
