module Foucault

  class KafkaConnection

    include Logging
    include Dry::Monads::Maybe::Mixin
    include Dry::Monads::Result::Mixin

    def connection
      self
    end

    def publish(topic, partition_key, event)
      client = kafka_client

      unless client.some?
        info "Foucault::KafkaConnection#publish Zookeeper connection failure, client: #{client.value_or}"
        return M::Failure(nil)
      end

      begin
        client.value_or.deliver_message(event, topic: topic, partition_key: partition_key)
        Success(nil)
      rescue Kafka::Error => e
        info "Foucault::KafkaChannel #{topic}; #{e}"
        Failure(nil)
      end
    end


    def topics
      return Maybe(nil) unless client.success?

      begin
        Maybe(client.value_or.topics)
      rescue StandardError
        Maybe(nil)
      end
    end

    private

    def kafka_client
      return Maybe(nil) unless kafka_broker_list.some?
      @client ||= Maybe(client_adapter.new(kafka_broker_list.value_or, client_id: configuration.config.kafka_client_id, logger: logger.configured_logger))
    end

    def kafka_broker_list
      @kafka_broker_list ||= kafka_brokers.new.()
    end

    def kafka_brokers
      KafkaBrokers
    end

    def configuration
      Configuration
    end

    def client_adapter
      Kafka
    end


  end

end
