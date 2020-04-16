module Foucault

  class MonadException < StandardError

    attr_reader :error_code, :retryable, :result

    def initialize(result: , code: nil, retryable: true)
      self.error_code = code
      @retryable = retryable
      @result = result
      super(nil)
    end

    def error_code=(code)
      if code
        @error_code = code
      else
        @error_code = "urn:port:error:#{self.class.to_s.downcase.gsub("::",":")}"
      end
    end

  end

end
