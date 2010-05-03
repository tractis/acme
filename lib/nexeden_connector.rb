require 'nexeden'

class NexedenConnector < Nexeden
  def self.create_challenge(transaction_id)
    response = self.request('/verifications', :post, :id => NEXEDEN_KEY, :transaction_id => transaction_id)
    if response['location']
      token = response['location'].split('/').last
      return response['location'], token
    else
      return nil, nil
    end
  end
  
  def self.valid_params?(api_key, params)
    parameters = {}
    params.each do |key, value|
      key = key.to_sym
      parameters[key] = value unless [:format, :action, :controller].include?(key)
    end
    parameters[:api_key] = api_key
    
    response = self.request('/data_verification', :post, parameters)
    if response.code == '200' and response.body == parameters[:verification_code]
      return true
    else
      return false
    end
  end
end
