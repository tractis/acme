# Include hook code here
#ActionController::Base.template_root = File.join(RAILS_ROOT, 'vendor/plugins/tractis_helpers/views')
ActionView::Base.send :include, TractisHelpers
ActionController::Base.send :include, TractisControllerHelpers
require 'email_address'
#require 'tractis_validations'
#require 'semantic_security'