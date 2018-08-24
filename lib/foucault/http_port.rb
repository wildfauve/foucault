class Foucault

  # include Discourse::Circuit

  def self.post(service:, resource:, hdrs:, body:, body_fn:, encoding:)
    Discourse::HttpPort.new.post do |p|
      p.service = service
      p.resource = resource
      p.request_headers = hdrs || {}
      p.request_body = body_fn.(body)
      p.encoding = encoding
    end.call
  end

  def self.put(service:, resource:, hdrs:, body:, body_fn:, encoding:)
    Discourse::HttpPort.new.put do |p|
      p.service = service
      p.resource = resource
      p.request_headers = hdrs || {}
      p.request_body = body_fn.(body)
      p.encoding = encoding
    end.call
  end

  def self.get(service:, resource:, query_params:, hdrs:, encoding:)
    Discourse::HttpPort.new.get do |p|
      p.service = service
      p.resource = resource
      p.request_headers = hdrs
      p.query_params = query_params
      p.encoding       = encoding
    end.call
  end

end
