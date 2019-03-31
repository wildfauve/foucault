module Foucault

  class GraphqlConnection

    include Dry::Monads::Try::Mixin
    include Dry::Monads::Result::Mixin

    GQL_CONNECTION_FAILURE = :gql_connection_failure

    def connection(endpoint, hdrs)
      @gql_connection = gql_connection(endpoint, hdrs)
      self
    end

    def query(query, query_vars)
      Try {
        @gql_connection.query(query, query_vars)
      }.to_result
    end

    private

    def gql_connection(endpoint, hdrs)
      begin
        Graphlient::Client.new(endpoint,
                                headers: {
                                  'Authorization' => hdrs[:authorization]
                                }
                              )
      rescue StandardError => e
        Failure([GQL_CONNECTION_FAILURE])
      end
    end

  end

end
