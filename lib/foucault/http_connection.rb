require 'faraday'
require 'typhoeus'
module Foucault

  class HttpConnection

    include Dry::Monads::Try::Mixin
    include Dry::Monads::Result::Mixin

    HTTP_CONNECTION_FAILURE = :http_connection_failure

    def connection(address, encoding, logging_level = nil, cache_store = nil, instrumenter = nil)
      @http_connection = http_connection(address, encoding, (Configuration.config.logging_level.to_sym || :info), cache_store, instrumenter)
      self
    end

    def get(hdrs, params)
      Try {
        @http_connection.get do |r|
          r.headers = hdrs if hdrs
          r.params = params if params
        end
      }.to_result
    end

    def post(hdrs, body)
      Try {
        @http_connection.post do |r|
          r.body = body
          r.headers = hdrs
        end
      }
    end

    def delete(hdrs)
      Try {
        @http_connection.delete do |r|
          r.headers = hdrs
        end
      }
    end

    private

    def http_connection(address, encoding, logging_level, cache_store, instrumenter)
      begin
        # caching = cache_options(cache_store, instrumenter)
        faraday_connection = Faraday.new(:url => address) do |faraday|
          # faraday.use :http_cache, caching if caching
          faraday.request  encoding if encoding
          faraday.response :logger do |log|
            log.filter(/(Bearer.)(.+)/, '\1[REMOVED]')
            log.filter(/(Basic.)(.+)/, '\1[REMOVED]')
            log.log_level(log_level)
          end
          faraday.adapter  :typhoeus
        end
        faraday_connection
      rescue StandardError => e
        Failure([HTTP_CONNECTION_FAILURE])
      end
    end

  end

end
