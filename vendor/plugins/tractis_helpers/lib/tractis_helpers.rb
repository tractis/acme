# TractisHelpers

module TractisHelpers
  def layout_partials
    ['layout/application',"#{params[:controller]}/layout"].each do |partial|
      render_if_exists :partial => partial
    end
    return nil
  end
  
  def render_if_exists(options)
    if options[:partial]
      partial = options[:partial]
    else
      raise ArgumentError, "This only works with partials"
    end
    name = partial.split("/")
    name[name.size-1] = "_#{name[name.size-1]}.rhtml"
    name = name.join("/")
    if defined?(RAILS_ROOT) && File.exists?("#{RAILS_ROOT}/app/views/#{name}")
      return render options
    end
    return nil
  end

  private
  def check_in(element, list)
    list[:only]   = [list[:only]].flatten if list[:only]
    list[:except] = [list[:except]].flatten if list[:except]
    raise "Wrong parameter #{list} is not a Hash" unless list.class == Hash
    return (    list[:only].include?(element))   if list[:only]
    return (not list[:except].include?(element)) if list[:except] 
    raise "parameters are incorrect"
  end

  def in_action?(actions={})
    check_in(params[:action],actions)
  end

  def in_controller?(controllers={})
    check_in(params[:controller],controllers)
  end

  def tab_link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    options[:controller] ||= params[:controller]
    options[:controller]   = options[:controller].to_s
    options[:action] = options[:action].to_s
    options[:css_selector] = true if options[:css_selector].nil? or options[:css_selector] != false
    if options[:action]
      html_options = {} unless html_options
      if in_action?(:only => options[:action]) and in_controller?(:only => options[:controller])
        if options[:css_selector]
          html_options.merge!({:class => "selected"})
        else
          return name
        end
      end
    end
    options.delete(:css_selector)
    return(link_to name, options, html_options, *parameters_for_method_reference)
  end
  
  def tab_link_to_controller(name, options = {}, html_options = nil, *parameters_for_method_reference)
    options[:controller] ||= params[:controller]
    options[:controller]   = options[:controller].to_s
    if options[:controller]
      html_options = {} unless html_options
      if in_controller?(:only => options[:controller])
        html_options.merge!({:class => "selected"})
      end
    end
    return(link_to name, options, html_options, *parameters_for_method_reference)
  end
  
  def abbr(string, size=20)
    if size < string.size
      content_tag(:abbr,truncate(string,size),:title => string)
    else
      string
    end
  end

  # ToDo: Refactor
  def show_flash
    txt = ""
    unless flash.empty?
      flash.each_key do |type|
        flash[type].each do |alert|
          txt << "  Alerts.#{type.to_s}(#{array_or_string_for_javascript(alert[:title])},#{array_or_string_for_javascript(alert[:msgs] || [])});\n"
        end unless flash[type].nil?
        flash[type] = nil
      end
      unless txt.blank?
        txt = "Alerts.initial(function(){\n#{txt}});" unless request.xml_http_request?
        txt = content_tag("script", javascript_cdata_section(txt), :type => "text/javascript") unless txt.blank?
        (txt = hidden_field_tag('alerts-shown', 'false') << txt) unless request.xml_http_request?
      end
    end
    txt = content_tag(:div, txt, :id => 'alerts')
    return txt
  end
  
  def javascript_tag(content, html_options = {})
    respond_to do |wants|
      wants.html {
        logger.debug "------> HTML"
        content_for 'scripts' do
          content + "\n"
        end
        return ''
      }
      wants.js {
        logger.debug "------> JavaScript"
        return content_tag("script", javascript_cdata_section(content), html_options.merge(:type => "text/javascript"))
      }
    end
  end
  
  def scripts
    unless @content_for_scripts.blank?
      content_tag("script", javascript_cdata_section(@content_for_scripts), :type => "text/javascript")
    else
      ""
    end
  end
  
  # refresh flash info in an ajax request
  def in_place_editor(field_id, options = {})
    if options[:collection]
      function =  "new Ajax.InPlaceCollectionEditor("
    else  
      function =  "new Ajax.InPlaceEditor("
    end
    function << "'#{field_id}', "
    function << "'#{url_for(options[:url])}'"
    
    options[:cancel_link]   ||= false
    options[:ok_button]     ||= false
    options[:submit_on_blur]  = options[:submit_on_blur].nil? ? true : options[:submit_on_blur]
    options[:saving_text]   ||= _("Saving...")
    options[:eval_on_change]  = options[:eval_on_change].nil? ? true : options[:submit_on_blur]
    
    js_options = {}
    js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
    js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
    js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
    js_options['savingText'] = %('#{options[:saving_text]}') if options[:saving_text]
    js_options['rows'] = options[:rows] if options[:rows]
    js_options['cols'] = options[:cols] if options[:cols]
    js_options['size'] = options[:size] if options[:size]
    js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
    js_options['loadTextURL'] = "'#{url_for(options[:load_text_url])}'" if options[:load_text_url]        
    js_options['ajaxOptions'] = options[:options] if options[:options]
    js_options['evalScripts'] = options[:script] if options[:script]
    js_options['callback']   = "function(form) { return #{options[:with]} }" if options[:with]
    js_options['clickToEditText'] = %('#{options[:click_to_edit_text]}') if options[:click_to_edit_text]
    js_options['cancelLink'] = options[:cancel_link] unless options[:cancel_link].nil?
    js_options['okButton'] = options[:ok_button] unless options[:ok_button].nil?
    js_options['submitOnBlur'] = options[:submit_on_blur] unless options[:submit_on_blur].nil?
    js_options['highlightcolor'] = %('#{options[:highlight_color]}') if options[:highlight_color]
    js_options['highlightendcolor'] = %('#{options[:highlight_end_color]}') if options[:highlight_end_color]
    js_options['paramName'] = %('#{options[:parameter]}') if options[:parameter]
    js_options['evalOnChange'] = options[:eval_on_change] unless options[:eval_on_change].nil?
    js_options['collection'] = options[:collection].inspect if options[:collection]
    function << (', ' + options_for_javascript(js_options)) unless js_options.empty?
    
    function << ')'
  
    javascript_tag(function)
  end
  
  def array_or_string_for_javascript(option)
    js_option = if option.kind_of?(Array)
      "[#{option.collect{ |opt| opt.inspect }.join(', ')}]"
    elsif !option.nil?
      "#{option.inspect}"
    end
    js_option
  end
  
  def statusquo_note(type='note', &block)
    content_for 'statusquo_notes' do
      content_tag(:div, capture(&block), :class => type)
    end
  end
end

class Module
  def memoized_finder(name, conditions=nil)
    class_eval <<-STR
      def #{name}(reload=false)
        @#{name} = nil if reload
        @#{name} ||= find(:all, :conditions => #{conditions.inspect})
      end
    STR
  end
end

class String
  # Generates a random string reordering randomly current time string chars.
  def self.random(str=nil)
    str ||= rand.to_s
    str << Time.now.to_i.to_s
    str.split(//).sort_by {rand}.join
  end
end