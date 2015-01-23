# Traffiq

Helpers to work with Queues.

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
