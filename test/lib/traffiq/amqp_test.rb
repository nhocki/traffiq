require 'test_helper'

module Traffiq
  class AMQPTest < Minitest::Spec
    let(:queue_url) { ENV['QUEUE_URL'] || "amqp://guest:guest@localhost:55672" }
    let(:amqp) { ::Traffiq::AMQP.new(queue_url) }

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

    describe "#publish" do
      let(:payload) {{ payload: :goes_here }}
      let(:json_payload) { '{"payload":"goes_here"}' }

      context "without an exchange" do
        it "raises an error" do
          assert_raises ::Traffiq::NoExchangeError do
            amqp.publish('routing_key', payload)
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
      end
    end

    describe "#subscribe" do
      context "without an exchange" do
        it "raises an error" do
          assert_raises ::Traffiq::NoExchangeError do
            amqp.subscribe('routing_key')
          end
        end
      end

      context "with an exchange" do
        it "binds to a queue"
      end
    end
  end
end
