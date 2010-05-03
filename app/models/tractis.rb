require 'net/http'
require 'net/https'
require 'uri'
require 'base64'

class PermissionsError < StandardError #:nodoc:
end

class Connections < Array
  FakeBase64 = Base64.encode64('email@example.com:password').strip
  def to_s
    str = ''
    self.each do |connection|
      if connection.is_a? Net::HTTPRequest
        str += "#{connection.method} #{connection.path} HTTP/1.1\n"
      else
        str += "HTTP/#{connection.http_version} #{connection.code} #{connection.message}\n"
      end
      connection.each_key do |key|
        output = connection[key]
        case key
        when 'authorization'
          output = "Basic #{FakeBase64}"
        when 'set-cookie', 'cookie'
          output.sub!(/_session_id=[^;]+/, '_session_id=sessionhash')
        when 'status', 'content-type', 'accept', 'content-length', 'host', 'location'
        else
          ##puts "--> #{key}: #{output}"
          next
        end
        header = key.split('-').map(&:capitalize).join('-')
        str += "#{header}: #{output}\n"
      end
      str += "\n"
      str += connection.body #[0..100]
      str += "\n-------------------\n"
    end
    return str
  end
end

TractisConnections = Connections.new

class Tractis
  attr_accessor :connections
  def self.config(user, password, url)
    @@user = user
    @@pass = password
    @@url  = url
  end
  
  def self.user
    return @@user
  end
  
  def self.url
    return @@url
  end
  
  def self.pass
    return @@pass
  end
private
  def self.init
    @@user ||= 'demo@negonation.com'
    @@pass ||= 'lsjfoijq32409rmlsjf094'
    @@url  ||= 'http://trunk.tractis.com'
  end
  
  def self.get_url(action='/')
   return URI.join(@@url, action)
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
      req.basic_auth @@user, @@pass
      yield(req) if block_given?
    
      TractisConnections << req
      response = http.request(req)
      unless response['content-type'] =~ /application\/xml/
        #puts response['content-type']
        raise IOError, "XML required, got #{response['content-type']}\n  #{action} might not be implemented in the API"
      end
      
      TractisConnections << response
      if response.class == Net::HTTPUnauthorized
        raise PermissionsError, 'Username or password are incorrect'
      end
    
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
  
  def self.login
    @logging_in = true
    response = request('/contracts') do |request|
      request.basic_auth @user, @pass
    end
    @logging_in = false
  end
end