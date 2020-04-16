require "spec_helper"
require 'logger'

RSpec.describe Foucault::Circuit do

  context 'Create Circuit' do

    subject { Foucault::Circuit }

    let(:failed_net_result) {
      Foucault::NetResponseValue.new(
        status: :fail,
        code: 500,
        body: {failure: "boom"}
      )
    }

    let(:success_net_result) {
      Foucault::NetResponseValue.new(
        status: :ok,
        code: 200,
        body: {thing: "a thing"}
      )
    }


    before do
      Stoplight::Light.default_data_store = Stoplight::DataStore::Memory.new
    end

    it "should succeed when there is no failures, and return the function's result" do
      circuit_fn = -> { "all_good" }

      circuit = subject.new(name: "success_test")

      result = circuit.(circuit_fn: circuit_fn)

      expect(circuit.colour).to eq "green"
      expect(circuit.failures).to be_empty
      expect(result).to eq "all_good"
    end

    it "should succeed when there the result is a success monad" do
      net_fn = -> { M::Success(success_net_result)  }

      circuit = subject.new(name: "success_test")

      result = circuit.(circuit_fn: subject.monad_circuit_wrapper_fn, caller: net_fn)

      expect(circuit.colour).to eq "green"
      expect(circuit.failures).to be_empty
      expect(result.value_or.body).to eq(thing: "a thing")
    end

    it "should throw a failure when the service returns a failure monad (not an exception) and returns the monad" do
      net_fn = -> { M::Failure(failed_net_result)  }

      circuit = subject.new(name: "failure_test")
      result = circuit.(circuit_fn: subject.monad_circuit_wrapper_fn, caller: net_fn)

      expect(circuit.colour).to eq "red"

      expect(result).to be_failure

      expect(result.failure.status).to eq :fail
      expect(result.failure.body).to eq(failure: "boom")
    end

  end


end
