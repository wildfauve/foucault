module Foucault
  class Net

    class << self

      def json_body_fn
        -> b { b.to_json }
      end

      # That is, not a circuit breaker
      # @param fn(Llambda)      : Must take the current retries as the last argument (when partially applied)
      # @param retries(Integer) : The max number of retries
      def retryer
        -> fn, retries {
          result = fn.()
          return result if result.success?
          return result if retries == 0
          retryer.(fn, retries - 1)
        }.curry
      end

      # def auth
      #   -> env, creds {
      #     ClientCredentialsGrant.new.(client_id: creds[:client_id], secret: creds[:client_secret], env: env)
      #   }.curry
      # end

      def post
        -> service, resource, hdrs, enc, body, body_fn {
          compose.(
            either.(http_ok).(http_ok_result).(failure),
            -> x { Adapter.post(service: service, resource: resource, body: body, body_fn: body_fn, hdrs: hdrs, encoding: enc) }
          ).(nil)
        }.curry
      end

      def put
        -> service, resource, hdrs, enc, body, body_fn {
          compose.(
            either.(http_ok).(http_ok_result).(failure),
            -> x { Adapter.put(service: service, resource: resource, body: body, body_fn: body_fn, hdrs: hdrs, encoding: enc) }
          ).(nil)
        }.curry
      end

      # @param service String
      # @param resource String
      # @param hdrs []
      # @param enc String
      # @param query
      # Example
      # > Nfn.get.(@env[:host], "/userinfo", {authorization: "Bearer <token> }, :url_encoded, {})
      def get
        -> service, resource, hdrs, enc, query {
          Fn.compose.(
            Fn.either.(http_ok).(http_ok_result).(Fn.failure),
            -> x { HttpPort.get(service: service, resource: resource, query_params: query, hdrs: hdrs, encoding: enc) }
          ).(nil)
        }.curry
      end


      def http_ok_result
        -> r { Fn.success.(r.body) }
      end

      def http_ok
        -> v { v.status == :ok }
      end

    end # class self

  end
end
