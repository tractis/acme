# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [ :action_web_service, :action_mailer, :active_record ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below
require 'tractis'

class Hash
  alias_method :previous_method_missing, :method_missing

  def method_missing(method_id, *arguments)
    method = method_id.to_s.gsub(/_/, '-').to_sym
    if self[method]
      return self[method]
    else
      super
    end
  end
  
  def to_xml_req(root='element')
    self.to_xml(:root => root, :skip_instruct => true, :skip_types => true).gsub(/members>/,'team')
  end
end

class String
  def from_xml
    XmlSimple.xml_in(self, 'ForceArray'=>false, 'noattr' => true, 'keytosymbol' => true)
  end
end

if ENV['RAILS_ENV'] == 'production'
  API = {
    :url => 'https://www.tractis.com',
    :user => 'acme@tractis.com',
    :password => 'negoacme07'
  }
  Tractis.config(API[:user], API[:password], API[:url])
  Nexeden.config('https://id.tractis.com')
  NEXEDEN_KEY = "9ca86cec7129ee9fdfadd156788f941189c579f9"
  NEXEDEN_URL = 'https://www.tractis.com'
else
  API = {
    :url => 'https://trunk.tractis.com',
    :user => 'erjica+demo@gmail.com',
    :password => '12344321'
  }
  Tractis.config(API[:user], API[:password], API[:url])
  Nexeden.config('http://trunk.tractis.com:8010')
  NEXEDEN_KEY = "11a5fdc55948db01de48cbcbeeba06fcb5bfb1e3"
  NEXEDEN_URL = 'http://trunk.tractis.com:8010'
end