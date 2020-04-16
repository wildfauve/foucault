require 'stoplight'

module Foucault

  class Circuit

    include Dry::Monads::Result::Mixin

    class MonadFailure < StandardError ; end

    MAX_RETRIES = 3

    include Logging

    attr_reader :circuit

    class << self

      # Provides a wrapper fn that allows a monad result to be thrown as an exception so that
      # Stoplight can execute retry behaviour.
      def monad_circuit_wrapper_fn
        -> caller { result = caller.(); result.success? ? result : raise(Foucault::MonadException.new(result: result)) }
      end
    end

    def initialize(name:, max_retries: MAX_RETRIES)
      # redis = Redis.new
      # datastore = Stoplight::DataStore::Redis.new(redis)
      # Stoplight::Light.default_data_store = datastore
      @name = name
      @max_retries = max_retries
    end

    def call(circuit_fn: , caller: nil)
      info(msg: "CircuitBreaker: #{circuit_to_s}", service_name: @name)
      @circuit = if caller.nil?
                    Stoplight(@name) { circuit_fn.() }.with_threshold(@max_retries).with_cool_off_time(10)
                  else
                    Stoplight(@name) { circuit_fn.(caller) }.with_threshold(@max_retries).with_cool_off_time(10)#.with_fallback {|e| binding.pry; e.result}
                  end
      run(@circuit)
    end

    def run(circuit)
      begin
        circuit.run
      rescue Stoplight::Error::RedLight => e
        info({msg: "CircuitBreaker: #{circuit_to_s}", service_name: @name, circuit_state: "red"})
        @last_error
      rescue Foucault::MonadException => e
        @last_error = e.result
        retry
      rescue StandardError => e
        @last_error = e
        retry
      end
    end

    def failures
      Stoplight::Light.default_data_store.get_failures(@circuit)
    end

    def colour
      @circuit.color
    end

    def circuit_failure
      NetResponseValue.new(
        status: NetResponseValue::CIRCUIT_RED,
        body: nil,
        code: 500
      )
    end

    def circuit_to_s
      "Circuit: #{@name}"
    end

  end

end
