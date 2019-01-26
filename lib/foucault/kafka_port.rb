module Foucault

  class KafkaPort

    class << self

      def publish
        -> topic, partition_key, body_fn, event {
          Fn.compose.(
            Fn.either.(net_ok).(Fn.success).(Fn.failure),
            response_value,
            deliver_message.(topic, partition_key, body_fn, event)
          ).(connection)
        }.curry
      end

      def deliver_message
        -> topic, partition_key, body_fn, event, connection {
          connection.publish(topic, partition_key, body_fn.(event))
        }.curry
      end

      def connection
        KafkaConnection.new.connection
      end

      def address
        -> service, resource { service + resource }.curry
      end

      def response_value
        -> response {
          NetResponseValue.new(
            status: evalulate_status.(response),
            code: nil,
            body: nil
          )
        }
      end

      def evalulate_status
        -> response {
          response.success? ? NetResponseValue::OK : NetResponseValue::FAIL
        }
      end

      def net_ok
        -> value { value.status == value.class::OK }
      end

    end  # class self

  end

end
