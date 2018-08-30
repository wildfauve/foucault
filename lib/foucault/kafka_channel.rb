module Discourse

  class KafkaChannel

    include Logging

    class RemoteServiceError < PortException ; end
    class KafkaServiceError < PortException ; end
    class DirectiveError < PortException ; end

    attr_accessor :topic, :event, :partition_key, :encoding

    attr_writer :representer

    def call()
      raise self.class::DirectiveError if event.nil?
      to_port()
    end

    private

    def to_port()
      begin
        msg = representer.(event)

        info "Discourse::KafkaChannel#to_port topic: #{topic}, message: #{msg}"

        connection = kafka_connection.new.connection(topic: topic, event: msg, partition_key: partition_key)

        connection.publish
        # returns a Maybe Monad, so, we'll throw an exception as this is the interface expected.
      rescue Discourse::PortException => e
        info "Discourse::KafkaChannel #{channel_to_s}; #{e}; retryable: #{e.retryable}"
        raise self.class::RemoteServiceError.new(msg: e.message, retryable: e.retryable)
      rescue Kafka::Error => e
        info "Discourse::KafkaChannel #{channel_to_s}; #{e}"
        raise self.class::KafkaServiceError.new(msg: e.message, retryable: false)
      end

    end

    def representer
      @representer || IC['object_to_json_representer']
    end

    def kafka_connection
      IC["kafka_connection"]
    end

    def channel_to_s
      "KafkaChannel: #{topic}"
    end

  end
end
