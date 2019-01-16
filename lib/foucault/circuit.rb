require 'stoplight'

module Foucault

  class Circuit

    # class CircuitOpen < PortException ; end
    # class CircuitUnavailable < PortException ; end

    MAX_RETRIES = 3

    include Logging

    attr_accessor :service_name

    def initialize()
      # redis = Redis.new
      # datastore = Stoplight::DataStore::Redis.new(redis)
      # Stoplight::Light.default_data_store = datastore
    end

    def call(fn)
      info "CircuitBreaker: #{circuit_to_s}; call service: #{service_name}"
      circuit = Stoplight(service_name) { fn.() }.with_threshold(MAX_RETRIES).with_cool_off_time(10)
      info "LIGHT ==== #{Stoplight::Light.default_data_store.get_all(circuit)}"
      run(circuit)

      # rescue ServiceDiscovery::ServiceDiscoveryNotAvailable => e
      #   info "CircuitBreaker: #{circuit_to_s}; Service Discovery unavailable"
      #   raise self.class::CircuitUnavailable.new(msg: e.cause)
      # rescue Stoplight::Error::RedLight => e
      #   info "CircuitBreaker: #{circuit_to_s}; Service: #{service_name} circuit red"
      #   raise self.class::CircuitOpen.new(msg: "Circuit Set to Red")
      # rescue PortException => e
      #   info "CircuitBreaker: #{circuit_to_s}; Exception Circuit Color==> #{circuit.color} #{e.inspect}"
      #   raise e unless e.retryable
      #   if circuit.color == Stoplight::Color::RED
      #     raise self.class::CircuitOpen.new(msg: e.cause)
      #   else
      #     retry
      #   end
      # end
    end

    def run(circuit)
      begin
        circuit.run
      rescue Stoplight::Error::RedLight => e
        info "CircuitBreaker: #{circuit_to_s}; Service: #{service_name} circuit red"
        Failure(nil)
      end
    end

    def circuit_to_s
      "Circuit: #{service_name}"
    end

  end

end
