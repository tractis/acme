#require '../../config/environment'
class Template < Tractis
  def self.create(params={})
    response = request('/templates', :post) do |req|
      req.body = params.to_xml_req('template')
      req.content_type = 'text/xml'
    end
    if response['location']
      return response['location'].split('/').last
    else
      return -1
    end
  end
  
  def self.find(id=:all)
    case id
    when :public
      response = request('/templates', :get)
      return [response.body.from_xml[:template]].flatten.compact
    when :all
      response = request('/templates/my_templates', :get, :per_page => 100)
      return [response.body.from_xml[:template]].flatten.compact
    when :first
      response = request('/templates/my_templates', :get, :per_page => 1, :page => 1)
      first = [response.body.from_xml[:template]].flatten.compact.first
      return Template.find(first[:id])
    else
      response = request("/templates/#{id}", :get)
      return response.body.from_xml
    end
  end
  
  def self.variables(id)
    response = request("/templates/#{id}/variables", :get)
    variables = response.body.from_xml
    return variables.blank? ? nil : variables
  end
end

#puts Template.find(:all).size
#puts TractisConnections.to_s