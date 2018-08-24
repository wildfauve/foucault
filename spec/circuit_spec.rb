require "spec_helper"
require 'logger'

RSpec.describe Foucault::Circuit do

  context 'Create Circuit' do

    subject { Foucault::Circuit }

    before do

      Stoplight::Light.default_data_store = Stoplight::DataStore::Memory.new



      # class MockClient
      #
      #   def circuit_test()
      #     # logger = Logger.new(STDOUT)
      #     # logger.level = Logger::DEBUG
      #
      #
      #
      #   end
    end

    # it "should succeed when there is no failures" do
    #   circuit_fn = -> { 1/1 }
    #   circuit_result = subject.new.(circuit_fn)
    #
    #   expect(circuit_result).to eq 1
    # end
    #
    # it "should throw a service unavailable exception when service discovery is unavailable" do
    #   circuit_fn = -> { M::Failure(nil)  }
    #   result = subject.new.(circuit_fn)
    #
    #   expect(result).to be_failure
    # end

  end


end
