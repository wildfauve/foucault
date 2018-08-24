RSpec.describe Foucault::Net do
  context "#retryer" do

  subject { Foucault::Net.retryer }

    it 'executes only once when the result is success' do
      retryable_fn = Fn.wrapper( -> { M.Success(nil) }.() )

      result = subject.(retryable_fn, 10)

      expect(result).to be_success
    end

    it 'executes all retries when each call fails' do
      retryable_fn = Fn.wrapper( -> { M.Failure(nil) }.() )

      result = subject.(retryable_fn, 10)

      expect(result).to be_failure
    end

  end

end
