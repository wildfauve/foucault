module Foucault

  class KafkaBrokers

    include Dry::Monads::Try::Mixin

    KAFKA_BROKER_IDS_PATH = "/brokers/ids"

    include Logging

    def call
      return Try(kafka_broker_list) if kafka_broker_list   # first check the config for the seeded brokers

      return Try(nil) unless zookeeper_client
      kafka_broker_list ? Try(kafka_broker_list) : brokers_from_zookeeper
    end

    private

    def brokers_from_zookeeper
      result = Try(zookeeper_client).bind(kafka_broker_ids)
                               .bind(kafka_brokers)
                               .bind(parse)
                               .bind(to_broker_address)
      zookeeper_client.close  # closes the connection to Zookeeper
      result
    end


    def kafka_broker_ids
      -> (zookeeper_client) { get_brokers_from_ids }
    end

    def get_brokers_from_ids
      begin
        ids = zookeeper_client.children(KAFKA_BROKER_IDS_PATH)
        ids.empty? ? Try(nil) : Try(ids)
      rescue Zookeeper::Exceptions::ZookeeperException => e
        Try(nil)
      rescue StandardError => e
        info "Zookeeper Discovery: Exception: #{e.message}"
        Try(nil)
      end
    end

    # {"listener_security_protocol_map"=>{"PLAINTEXT"=>"PLAINTEXT"},
    #  "endpoints"=>["PLAINTEXT://192.168.0.12:9092"],
    #  "jmx_port"=>-1,
    #  "host"=>"192.168.0.12",
    #  "timestamp"=>"1498435530996",
    #  "port"=>9092,
    #  "version"=>4}

    def kafka_brokers
      ->(ids) { Try(ids.map { |id| zookeeper_client.get("#{KAFKA_BROKER_IDS_PATH}/#{id}")[0] }
                            .flatten.delete_if(&:nil?) ) }
    end

    def to_broker_address#(broker)
      -> (brokers) { Try(brokers.map { |broker| "#{broker["host"]}:#{broker["port"]}" } ) }
    end
    
    def parse
      ->(data) { Try(data.map { |d| JSON.parse(d) } ) }
    end

    def zookeeper_client
      begin
        @zookeeper_client ||= ZK.new(broker_list) if broker_list
      rescue StandardError => e
        info "Zookeeper Discovery: Exception: #{e.message}"
        nil
      end
    end

    def broker_list
      unless configuration.config.zookeeper_broker_list || configuration.config.kafka_broker_list
        error "Foucault::Zookeeper; zookeeper_broker_list not set"
        return
      end
      configuration.config.zookeeper_broker_list
    end

    def kafka_broker_list
      Fn.split.(",").(configuration.config.kafka_broker_list) unless configuration.config.kafka_broker_list.nil?
    end

    def configuration
      Configuration
    end

  end

end
