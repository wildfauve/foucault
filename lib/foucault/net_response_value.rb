module Foucault

  class NetResponseValue < Dry::Struct

    FAIL                 = :fail
    OK                   = :ok
    BAD_REQUEST          = :bad_request
    UNAUTHORISED         = :unauthorised
    NOT_FOUND            = :not_found
    SYSTEM_FAILURE       = :system_failure
    UNPROCESSABLE_ENTITY = :unprocessable_entity

    NET_STATUS           = Types::Strict::Symbol.enum(OK, FAIL, BAD_REQUEST, UNAUTHORISED, NOT_FOUND, SYSTEM_FAILURE, UNPROCESSABLE_ENTITY)

    attribute :status,          NET_STATUS
    attribute :code,            Types::Integer.optional
    attribute :body,            Types::Nominal::Any.optional

  end

end
