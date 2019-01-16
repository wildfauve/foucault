module Foucault

  class HttpPort

    class << self

      def post
        -> service, resource, hdrs, body_fn, enc, body {
          Fn.compose.(
            Fn.either.(net_ok).(Fn.success).(Fn.failure),
            response_value,
            run_post.(hdrs, body_fn, body),
            addressed.(service, resource),
          ).(connection.(enc))
        }
      end

      def get
        -> service, resource, hdrs, enc, query {
          Fn.compose.(
            Fn.either.(net_ok).(Fn.success).(Fn.failure),
            response_value,
            run_get.(hdrs, query),
            addressed.(service, resource),
          ).(connection.(enc))
        }
      end

      def delete
        -> service, resource, hdrs {
          Fn.compose.(
            Fn.either.(net_ok).(Fn.success).(Fn.failure),
            response_value,
            run_delete.(hdrs),
            addressed.(service, resource),
          ).(connection.(nil))
        }
      end


      def run_post
        -> hdrs, body_fn, body, connection {
          connection.post(hdrs, body_fn.(body))
        }.curry
      end

      def run_get
        -> hdrs, query, connection {
          connection.get(hdrs, query)
        }.curry
      end

      def run_delete
        -> hdrs, connection {
          connection.delete(hdrs)
        }.curry
      end

      def addressed
        -> service, resource, connection {
          connection.(address.(service, resource))
        }.curry
      end

      def connection
        -> encoding, address { HttpConnection.new.connection(address, encoding) }.curry
      end

      def address
        -> service, resource { service + resource }.curry
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
          when 500..530
            NetResponseValue::SYSTEM_FAILURE
          else
            NetResponseValue::FAIL
          end
        }
      end

      def response_body_parser
        Fn.compose.(
          parser_fn,
          Fn.at.(0),
          Fn.split.(";")
        )
      end

      def parser_fn
        -> type {
          case type
          when "text/html"
            html_parser
          when "text/plain"
            text_parser
          when "application/json"
            json_parser
          when "application/xml", "application/soap+xml", "text/xml"
            xml_parser
          else
            json_parser
          end
        }
      end

      def returned_response(response)
        NetResponseValue.new(
          status: evalulate_status.(response.value_or.status),
          body: response_body_parser.(response.value_or.headers["content-type"]).(response.value_or)
        )
      end

      def catastrophic_failure
        NetResponseValue.new(
          status: NetResponseValue::SYSTEM_FAILURE,
          body: nil
        )
      end

      def html_parser
        -> response { Nokogiri::XML(response.body) }
      end

      def xml_parser
        -> response { Nokogiri::XML(response.body) }
      end

      def json_parser
        -> response { JSON.parse(response.body) }
      end

      def text_parser
        -> response { response.body }
      end

      def net_ok
        -> value { value.status == value.class::OK }
      end

    end

  end

end
