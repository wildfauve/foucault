require 'base64'

module Foucault
  class Net

    class << self

      def publish
        -> topic, partition_key, body_fn, event {
          KafkaPort.publish.(topic, partition_key, body_fn, event)
        }.curry
      end

      # def auth
      #   -> env, creds {
      #     ClientCredentialsGrant.new.(client_id: creds[:client_id], secret: creds[:client_secret], env: env)
      #   }.curry
      # end

      def post
        -> service, resource, hdrs, enc, body_fn, body {
          HttpPort.post.(service, resource, body_fn, enc, body)
        }.curry
      end

      # @param service String
      # @param resource String
      # @param hdrs []
      # @param enc String
      # @param query
      # @return Result(NetResponseValue)
      # Example
      # > get.(@env[:host], "/userinfo", {authorization: "Bearer <token> }, :url_encoded, {} )
      def get
        -> service, resource, hdrs, enc, query {
            HttpPort.get.(service, resource, hdrs, enc, query)
        }.curry
      end


      # That is, not a circuit breaker
      # @param fn(Llambda)      : A partially applied fn
      # @param args             : The function's arguments as either an array or hash
      # @param retries(Integer) : The max number of retries
      def retryer
        -> fn, args, retries {
          result = fn.(*args)
          return result if result.success?
          return result if retries == 0
          retryer.(fn, args, retries - 1)
        }.curry
      end

      # (a -> a) -> Hash
      # @param c [String] : Client or user
      # @param s [String] : secret or password
      # @return [Hash{Symbol=>String}]
      def basic_auth_header
        -> c, s {
          { authorization: ("Basic " + Base64::strict_encode64("#{c}:#{s}")).chomp }
        }.curry
      end

      # @param  Array[Hash]
      # @return [Hash{Symbol=>String}]
      def header_builder
        -> *hdrs { Fn.inject.({}).(Fn.merge).(hdrs) }
      end

      def json_body_fn
        -> body { body.to_json }
      end

    end # class self

  end
end
