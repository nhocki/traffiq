require 'test_helper'

module Traffiq
  class AMQPTest < Minitest::Spec
    let(:default_port) { ENV['BOXEN_HOME'] ? 55672 : 5672 }
    let(:queue_url) { ENV['QUEUE_URL'] || "amqp://guest:guest@localhost:#{default_port}" }
    let(:amqp) { ::Traffiq::AMQP.new(queue_url) }
    let(:payload) {{ payload: :goes_here }}
    let(:routing_key) { 'routing_key' }
    let(:json_payload) { '{"payload":"goes_here"}' }

    after do
      amqp.close
    end

    describe '#initialize' do
      it "connects to a queue and creates a channel" do
        amqp = ::Traffiq::AMQP.new(queue_url)
        assert amqp.connected?
      end
    end

    describe '#define_exchange' do
      let(:exchange_name) { 'new_exchange' }
      let(:exchange) { amqp.exchanges[exchange_name] }

      before do
        amqp.define_exchange(exchange_name)
      end

      it "defines a topic exchange with the exchange name" do
        assert_equal 1, amqp.exchanges.size
        refute_nil exchange
        assert_equal :topic, exchange.type
      end

      it "defines a durable and non auto-delete exchange" do
        assert exchange.durable?
        refute exchange.auto_delete?
      end
    end

    describe "#bind_queue" do
      context "without an exchange" do
        it "raises an error" do
          assert_raises ::Traffiq::NoExchangeError do
            amqp.bind_queue(routing_key)
          end
        end
      end

      context "with an exchange" do
        before do
          amqp.define_exchange('traffiq_test')
        end

        it "creates a queue" do
          queue = amqp.bind_queue(routing_key)
          refute_nil queue

          assert_equal 1, amqp.queues.length
          assert_equal queue, amqp.queues[routing_key]
        end
      end
    end

    describe "#publish" do
      context "without an exchange" do
        it "raises an error" do
          assert_raises ::Traffiq::NoExchangeError do
            amqp.publish(routing_key, payload)
          end
        end
      end

      context "with an exchange" do
        before do
          amqp.define_exchange('traffiq_test')
        end

        it "pushes a message with a specific routing key and as JSON" do
          amqp.exchange.expects(:publish).
            with(json_payload, routing_key: 'test_routing_key', persistent: true).
            once
          amqp.publish('test_routing_key', payload)
        end

        it "doesn't bind to a queue by default" do
          amqp.publish('test_routing_key', payload)
          assert_empty amqp.queues
        end

        it "binds to a queue if you want it to" do
          amqp.publish('test_routing_key', payload, bind_to_queue: true)
          refute_empty amqp.queues
          refute_nil amqp.queues['test_routing_key']
        end
      end
    end

    describe "#subscribe" do
      let(:noop) {  lambda{ |_,_,_| }}
      context "without an exchange" do
        it "raises an error" do
          assert_raises ::Traffiq::NoExchangeError do
            amqp.subscribe(routing_key, &noop)
          end
        end
      end

      context "with an exchange" do
        before do
          amqp.define_exchange('traffiq_test')
        end

        it "binds to a routing key" do
          amqp.subscribe(routing_key, &noop)
          assert_equal 1, amqp.queues.length

          queue = amqp.queues[routing_key]
          refute_nil queue
          assert_equal routing_key, queue.name
        end

        it "executes the block with the payload when something is published" do
          amqp.subscribe(routing_key) do |delivery_info, metadata, q_payload|
            refute_nil delivery_info
            refute_nil metadata
            refute_nil q_payload
            assert_equal json_payload, q_payload
          end

          amqp.publish('test_routing_key', payload)
        end
      end
    end
  end
end
