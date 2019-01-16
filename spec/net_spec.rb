RSpec.describe Foucault::Net do

  subject { Foucault::Net }

  context "#retryer" do

    it 'executes only once when the result is success' do
      retryable_fn = -> x { M.Success(x) }

      result = subject.retryer.(retryable_fn, [1], 10)

      expect(result).to be_success
      expect(result.value_or).to eq 1
    end

    it 'executes all retries when each call fails' do
      retryable_fn = -> x { M.Failure(nil) }

      result = subject.retryer.(retryable_fn, [2], 10)

      expect(result).to be_failure
      expect(result.failure).to eq nil
    end

  end

  context "#decode_basic_auth" do

    it 'decodes a valid authorisation header' do
      auth = subject.basic_auth_header.("username").("password")[:authorization]

      result = subject.decode_basic_auth.(auth)
      expect(result).to be_success
      expect(result.value_or[0]).to eq "username"
    end

    it 'fails when the header is not valid' do
      result = subject.decode_basic_auth.("invalid_auth")
      expect(result).to be_failure
    end
  end


end
