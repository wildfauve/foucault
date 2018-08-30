module Foucault

  class HttpPort

    class << self

      def post
        -> service, resource, body_fn, enc, body {
          Fn.compose.(
            Fn.either.(http_ok).(Fn.success).(Fn.failure),
            response_value,
            run_post.(body_fn, body),
            addressed.(service, resource),
          ).(connection.(enc))
        }
      end

# service, resource, hdrs, enc, query
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

      def run_post
        -> body_fn, body, connection {
          connection.post do |r|
            r.body = body_fn.(body)
          end
        }.curry
      end

      def run_get
        -> hdrs, query, connection {
          connection.get do |r|
            r.headers = hdrs
            r.params = query
          end
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
          NetResponseValue.new(
            status: evalulate_status.(response.status),
            body: response_body_parser.(response.headers["content-type"]).(response)
          )
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
          when "application/json"
            json_parser
          when "application/xml"
            xml_parser
          when "text/xml"
            xml_parser
          else
            default_parse
          end
        }
      end

      def html_parser
        -> response { Nokogiri::XML(response.body) }
      end

      def xml_parse
        -> response { Nokogiri::XML(response.body) }
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
