ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'cert_auth' do |auth|
    auth.cert_auth_login '/cert_auth', :action => 'index'
    auth.cert_auth_gateway '/cert_auth/auth', :action => 'login'
    auth.cert_auth_private '/cert_auth/private', :action => 'private'
  end
  
  map.with_options :controller => 'id_mailing' do |auth|
    auth.id_mailing '/id_mailing', :action => 'index', :conditions => {:method => :get}
    #auth.connect '/id_mailing', :action => 'create', :conditions => {:method => :post}
  end
  
  map.login_contracts '/contracts/auth', :controller => 'contracts', :action => 'login'
  map.resources :contracts, :collection => {:variables => :get, :live_xml => :get}
  map.dashboard '/', :controller => 'index', :action => 'index'

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
