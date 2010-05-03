
class ContractsController < ApplicationController
  # GET /contracts
  # GET /contracts.xml
  def variables
    begin
      @variables = Template.variables(params[:contract][:template])
    rescue IOError
      @variables = false
    end
    render :layout => false
  end
  
  def live_xml
    render :layout => false
  end

  # GET /contracts/new
  def new
    @templates = Template.find(:all)
    if @templates.blank?
      notify :error, "This account doesn\'t have any template"
      redirect_to login_contracts_path
      return
    end
    render :action => 'new'
  rescue PermissionsError  
    notify :error, "Your Tractis ID information is not valid", "Please, try again"
    redirect_to login_contracts_path
  end
  
  def index
    redirect_to new_contract_path
  end
  
  def login
    if params[:clear]
      session[:login] = nil
      session[:password] = nil
      redirect_to new_contract_path
    elsif params[:login]
      session[:login] = params[:login]
      session[:password] = params[:password]
      redirect_to new_contract_path
    end
  end

  # POST /contracts
  # POST /contracts.xml
  def create
    @errors  ||= []
    @contracts = []
    params[:contracts].each do |contract|
      c = Contract.create(contract)
      if c
        @contracts << c
      else
        @errors << "Couldn\'t create contract for #{contract[:team][:member][:email]}"
      end
    end if @errors.blank?
    if @errors.blank?
      notify :notice, 'Contracts succesfully created'
      redirect_to new_contract_path
    else
      error_messages
      self.send(:new)
    end
  end
private
  after_filter :log_tractis_connections
  def log_tractis_connections
    logger.debug TractisConnections.to_s
    logger.debug "===> #{Tractis.user}"
  end
  
  before_filter :set_auth_for_the_api
  def set_auth_for_the_api
    if logged_in?
      @user = session[:login]
      @pass = session[:password] || ''
    else
      @user = API[:user]
      @pass = API[:password]
    end
    Tractis.config(@user, @pass, API[:url])
  end
  
  before_filter :prepare_contract_params
  def prepare_contract_params
    return true unless params[:contract]
    @errors = []
    params[:contract].each_key do |key|
      params[:contract].delete(key) if params[:contract][key].blank?
    end
    
    if params[:email].blank? or params[:email].first.blank?
      @errors << 'You have to specify an email address'
    end
    if params[:contract][:name].nil?
      @errors << 'You have to specify a name'
    end
    
    return true unless @errors.blank?
    #if not params[:contract][:creator_is_signer] or params[:contract][:creator_is_signer] == '0'
    #  params[:contract][:creator_is_signer] = false
    #else
    #  params[:contract][:creator_is_signer] = true
    #end
    
    params[:contract][:sticky_notes] = true unless params[:contract][:notes].blank?
    #params[:contract][:allow_simple_accept] = true
    params[:contract][:show_menu] = false

    params[:contracts] = []
    params[:email].each do |email|
      next if email.blank?
      email = CGI.unescape(CGI.unescape(email)).strip
      unless email =~ EmailAddress::RegExp
        @errors << "Email '#{email}' is invalid"
        next
      end
      contract = params[:contract].dup
      member = {
        :email => email,
        :invited => false,
        :sign => true
      }
      member[:message] = {}
      params[:invitation] ||= {}
      params[:invitation].each do |key, value|
        next if value.blank?
        member[:message][key] = value
      end
      member.delete(:message) if member[:message].blank?
      contract[:team] = {}
      contract[:team][:member] = member
      params[:contracts] << contract
    end
  end
  
  def error_messages
    if @errors.size == 1
      text = @errors.shift
    else
      text = "Errors found"
    end
    notify :error, text, @errors
  end
  
  helper_method :logged_in?
  def logged_in?
    return(not session[:login].nil?)
  end
end
