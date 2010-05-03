class Contract < Tractis
  def self.create(params={})
    response = Contract.request('/contracts', :post) do |req|
      req.body = params.to_xml_req('contract')
      req.content_type = 'text/xml'
    end
    if response['location']
      id = response['location'].split('/').last
      return id
    else
      return nil
    end
  end
  
  def self.find(id=:all)
    case id
    when :all
      response = request('/contracts', :get)
      return  [response.body.from_xml[:contract]].flatten
    when :first
      response = request('/contracts', :get)
      first = [response.body.from_xml[:contract]].flatten.first
      return Contract.find(first[:id])
    else
      response = request("/contracts/#{id}", :get)
      return response.body.from_xml
    end
  end
end