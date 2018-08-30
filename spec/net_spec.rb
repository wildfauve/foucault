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


end
