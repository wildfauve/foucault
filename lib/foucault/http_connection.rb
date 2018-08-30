require 'faraday'
require 'typhoeus'
module Foucault

  class HttpConnection

    HTTP_CONNECTION_FAILURE = :http_connection_failure

    def connection(address, encoding, cache_store = nil, instrumenter = nil)
      @http_connection = http_connection(address, encoding, cache_store = nil, instrumenter = nil)
      self
    end

    def get(hdrs, params)
      M.Try {
        @http_connection.get do |r|
          r.headers = hdrs
          r.params = params
        end
      }.to_result
    end

    def post(body)
      M.Try {
        @http_connection.post do |r|
          r.body = body
        end
      }
    end

    private

    def http_connection(address, encoding, cache_store = nil, instrumenter = nil)
      begin
        # caching = cache_options(cache_store, instrumenter)
        faraday_connection = Faraday.new(:url => address) do |faraday|
          # faraday.use :http_cache, caching if caching
          faraday.request  encoding if encoding
          faraday.response :logger
          faraday.adapter  :typhoeus
        end
        faraday_connection
      rescue StandardError => e
        M.Failure([HTTP_CONNECTION_FAILURE])
      end
    end

  end

end
