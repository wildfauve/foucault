module Foucault

  class GraphqlPort

    class << self

      def query
        -> endpoint, hdrs, query, query_vars {
          Fn.compose.(
            Fn.either.(net_ok).(Fn.success).(Fn.failure),
            response_value,
            run_query.(query, query_vars)
          ).(connection.(endpoint, hdrs))
        }.curry
      end


      def run_query
        -> query, query_vars, connection {
          connection.query(query, query_vars)
        }.curry
      end

      def connection
        -> endpoint, hdrs { GraphqlConnection.new.connection(endpoint, hdrs) }.curry
      end

      def response_value
        -> response {
          response.success? ? returned_response(response) : catastrophic_failure
        }
      end

      def evalulate_status
        -> status {
          case status
          when 200..300
            NetResponseValue::OK
          when 401, 403
            NetResponseValue::UNAUTHORISED
          when 422
            NetResponseValue::UNPROCESSABLE_ENTITY
          when 500..530
            NetResponseValue::SYSTEM_FAILURE
          else
            NetResponseValue::FAIL
          end
        }
      end

      def returned_response(response)
        NetResponseValue.new(
          status: NetResponseValue::OK,
          code: 200,
          body: response.value_or
        )
      end

      def catastrophic_failure
        NetResponseValue.new(
          status: NetResponseValue::SYSTEM_FAILURE,
          body: nil,
          code: 500
        )
      end

      def json_parser
        -> response { JSON.parse(response.body) }
      end

      def net_ok
        -> value { value.status == value.class::OK }
      end

    end

  end

end
