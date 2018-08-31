module Foucault

  class KafkaConnection

    include Logging

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
        M::Success(nil)
      rescue Kafka::Error => e
        info "Foucault::KafkaChannel #{topic}; #{e}"
        M::Failure(nil)
      end
    end


    def topics
      return M::Maybe(nil) unless client.success?

      begin
        M::Maybe(client.value_or.topics)
      rescue StandardError
        M::Maybe(nil)
      end
    end

    private

    def kafka_client
      return M::Maybe(nil) unless kafka_broker_list.some?
      @client ||= M::Maybe(client_adapter.new(kafka_broker_list.value_or, client_id: configuration.config.kafka_client_id, logger: logger.configured_logger))
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
