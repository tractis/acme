require File.dirname(__FILE__) + '/../test_helper'
require 'contracts_controller'

# Re-raise errors caught by the controller.
class ContractsController; def rescue_action(e) raise e end; end

class ContractsControllerTest < Test::Unit::TestCase

  def setup
    @controller = ContractsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_redirected_to new_contract_path
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_contract
    post :create, :email => ['pepe@test.com'], :contract => {:name => 'hola'}
    
    assert_redirected_to new_contract_path
  end
  
  def test_shouldnt_create_contract
    post :create, :email => ['pepe@test.com'], :contract => {}
    
    assert_response :success
  end
  
  def test_login_contracts
    get :login
    assert_response :success
  end
  
  def test_login_contracts
    get :login
    assert_response :success
  end
  
  def test_incorrect_login_should_redirect_to_login_form
    @request.session[:login] = 'unknown@example.com'
    @request.session[:password] = 'none'
    get :new
    assert_redirected_to login_contracts_path
  end
end
