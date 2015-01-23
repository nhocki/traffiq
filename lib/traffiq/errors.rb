module Traffiq
  class Error < StandardError
    def initialize(msg = nil)
      super(msg || default_message)
    end

    private
    def default_message
      "Traffiq error"
    end
  end

  class NoExchangeError < Error
    private
    def default_message
      "Must define exchange"
    end
  end
end
