require "spec_helper"

RSpec.describe Foucault::Net do

  context 'successful publishing' do

    subject { Foucault::Net }

      before do

        class ClientDouble
          def initialize(*args) ; self ; end
          def client ; M.Maybe(self) ; end
          def deliver_message(*args); nil ; end
        end

      end

    it 'publishes like a happy bunny' do

      allow_any_instance_of(Foucault::KafkaConnection).to receive(:kafka_client).and_return(M.Maybe(ClientDouble.new))

      result = subject.publish.("io.mindainfo.account.transaction", "123", subject.json_body_fn, { kind: :event } )

      expect(result).to be_success
      expect(result.value_or.body).to be_nil
      expect(result.value_or.status).to eq :ok

    end
  end

  context 'successful publishing' do

    subject { Foucault::Net }

      before do

        class ClientDouble
          def initialize(*args) ; self ; end
          def client ; M.Maybe(self) ; end
          def deliver_message(*args); raise Kafka::Error ; end
        end

      end

    it 'Kafka returns an error' do

      allow_any_instance_of(Foucault::KafkaConnection).to receive(:kafka_client).and_return(M.Maybe(ClientDouble.new))

      result = subject.publish.("io.mindainfo.account.transaction", "123", subject.json_body_fn, { kind: :event } )

      expect(result).to be_failure
      expect(result.failure.body).to be_nil
      expect(result.failure.status).to eq :fail

    end
  end

  context 'problems finding brokers' do

    before do
      class ConnectionDouble
        def connection(*args) ; self ; end
        def publish(*args)
          raise Foucault::KafkaConnection::ZookeeperFailure.new(msg: "Zookeeper connection failure", retryable: false)
        end
      end

      Foucault::IC.enable_stubs!
      Foucault::IC.stub('kafka_connection', ConnectionDouble)
    end

    after do
      Foucault::IC.unstub('kafka_connection')
    end

    it 'should return a none' do

      channel = Foucault::KafkaPort.new.send do |p|
        p.topic = "topic"
        p.event = { kind: :event }
        p.partition_key = "123"
      end

      expect { channel.() }.to raise_error(Foucault::KafkaChannel::RemoteServiceError)

    end

  end

end
