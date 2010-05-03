module ContractsHelper
  def build_form_from_variables_hash(variables, prefix = "auto_complete", title = nil)
    fields = []
    sub    = []
    variables.each do |key, v|
      key_s = key.to_s.gsub('-', '_')
      v = [v].flatten
      v.each do |value|
        value = '' if value.blank?
        if value.class == String
          if variables[key].class == Array
            field_name = "#{prefix.to_s}[#{key_s}:]"
          else
            field_name = "#{prefix.to_s}[#{key_s}]"
          end
          input = text_field_tag(field_name, value.gsub(/\n/, ' '))
          fields << content_tag(:label, key_s.capitalize.gsub(/_/,' ') + ' ' + input)
        else
          sub << build_form_from_variables_hash(value, "#{prefix.to_s}[#{key_s}]", key_s)
        end
      end
    end
    sub.sort!
    fields.map!(&:to_s).sort!
    form = ""
    if title
      form += content_tag(:legend, title.gsub(/_/,' ').downcase.capitalize) if title
      form += fields.join('')
    else
      form += content_tag(:div,fields.join(''),:class => 'moduloB variables')
    end
    sub.each do |f|
      form += f
    end
    form = content_tag(:fieldset, form) if title
    return form
  end
end
