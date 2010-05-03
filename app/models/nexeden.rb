#require 'rubygems'
require 'tractis'
#require 'active_support'

class Nexeden
  def self.config(url)
    @@url = url
  end
  
private
  def self.init
    @@url ||= 'http://trunk.tractis.com'
  end

  def self.get_url(action='/')
    return URI.join(NEXEDEN_URL, action)
  end

  def self.request(action='/', method=:get, params={}, &block)
    init
    #puts "-> #{action}"
    klass = get_klass_according_to_method(method)
    url = get_url(action)
    #puts "    #{url.host}:#{url.port}#{url.request_uri}"
    sock = Net::HTTP.new(url.host, url.port)
    sock.use_ssl = true if url.port == 443

    path = url.path
    if method == :get and params
      path << '?'
      params.each do |key, value|
        path << "#{key}=#{value}"
      end
    end

    sock.start do |http|
      req = klass.new(path, {'Accept' => 'application/xml'})
      if params
        req.set_form_data(params)
      end
      yield(req) if block_given?

      TractisConnections << req
      response = http.request(req)
      
      TractisConnections << response
      
      ##puts response.body[0..500]

      return response
    end
  end

  def self.get_klass_according_to_method(method)
    case method
    when :post
      klass = Net::HTTP::Post
    when :put
      klass = Net::HTTP::Put
    when :delete
      klass = Net::HTTP::Delete
    else
      klass = Net::HTTP::Get
    end
    return klass
  end
end