RSpec.describe Foucault::Net do

  subject { Foucault::Net }

  # context "#get" do
  #
  #   it 'tries a real get--dont forget to comment out!' do
  #     result = subject.get.("http://api.example.com", "/resource", {authorization: "uid:pwd"}, :url_encoded, {param1: 1})
  #   end
  #
  #   it 'uses the retryer' do
  #     fn = subject.get
  #     args = ["http://api.example.com", "/resource", {authorization: "uid:pwd"}, :url_encoded, {param1: 1}]
  #
  #     result = subject.retryer.(fn, args, 10)
  #   end
  #
  # end

  context "#post" do

    let(:json_response)  {double("http_resp", body: '{"message" : "I am json"} ', status: 201,
                                    headers: {"content-type"=>"application/json"})
                         }

    let(:no_content_response)  {double("http_resp", body: '{"message" : "I am json"} ', status: 201,
                                   headers: {"content-type"=>nil})
                        }



    let(:faraday_request_object) { double("request", :headers= => {}, :body= => {}) }

    let(:faraday_connection_object) { double("connection", use: faraday_request_object,
                                                           response: faraday_request_object,
                                                           adapter: faraday_request_object,
                                                           request: :url_encoded)
                                                           }


    it 'posts to the http resource' do

      expect(Faraday).to receive(:new).with(url: "http://api.example.com/resource").and_yield(faraday_connection_object)

      expect(faraday_request_object).to receive(:post).and_yield(faraday_request_object).and_return(json_response)

      result = subject.post.("http://api.example.com", "/resource", {}, nil, subject.json_body_fn, {message: "some message"})

      expect(result).to be_success
      expect(result.value_or.status).to be :ok
      expect(result.value_or.body).to eq({"message" => "I am json"})

    end

    it 'posts using a circuit' do
      expect(Faraday).to receive(:new).with(url: "http://api.example.com/resource").and_yield(faraday_connection_object)

      expect(faraday_request_object).to receive(:post).and_yield(faraday_request_object).and_return(json_response)

      caller = Fn.wrapper.(subject.post.("http://api.example.com", "/resource", {}, nil, subject.json_body_fn, {message: "some message"}))

      circuit = Foucault::Circuit.new(name: "http_test")

      result = circuit.(circuit_fn: Foucault::Circuit.monad_circuit_wrapper_fn, caller: caller)

      expect(result).to be_success
      expect(result.value_or.status).to be :ok
      expect(result.value_or.body).to eq({"message" => "I am json"})

    end

    it 'posts but does not return a content type' do
      expect(Faraday).to receive(:new).with(url: "http://api.example.com/resource").and_yield(faraday_connection_object)

      expect(faraday_request_object).to receive(:post).and_yield(faraday_request_object).and_return(no_content_response)

      result = subject.post.("http://api.example.com", "/resource", {}, nil, subject.json_body_fn, {message: "some message"})

      expect(result).to be_failure
      expect(result.failure.status).to be :system_failure

    end

    it 'fails when the URL is invalid' do

      result = subject.post.(nil, nil, {}, nil, subject.json_body_fn, {message: "some message"})

      expect(result).to be_failure

    end

  end # context

  context "#get" do

    let(:json_response)  {double("http_resp", body: '{"message" : "I am json"} ', status: 200,
                                    headers: {"content-type"=>"application/json"})
                         }

    let(:faraday_request_object) { double("request") }

    let(:faraday_connection_object) { double("connection", use: faraday_request_object,
                                                           response: faraday_request_object,
                                                           adapter: faraday_request_object,
                                                           request: :url_encoded)
                                                           }



    it "gets from the port with headers and params" do

      expect(Faraday).to receive(:new).with(url: "http://api.example.com/resource").and_yield(faraday_connection_object)

      expect(faraday_request_object).to receive(:get).and_yield(faraday_request_object).and_return(json_response)

      expect(faraday_request_object).to receive(:headers=).with({:authorization=>"uid:pwd"})
      expect(faraday_request_object).to receive(:params=).with({param1: 1})


      result = subject.get.("http://api.example.com", "/resource", {authorization: "uid:pwd"}, :url_encoded, {param1: 1})

      expect(result).to be_success
      expect(result.value_or.body).to eq({"message"=>"I am json"})
      expect(result.value_or.status).to eq :ok

    end

  end

end
