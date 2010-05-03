module ActiveRecord
  module Validations
    module ClassMethods
      def validates_is_email(*attr_names)
        configuration = { :message => _("Email is invalid"), :on => :save, :with => EmailAddress::RegExp }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
        
        validates_each(attr_names, configuration) do |record, attr_name, value|
          record.errors.add(attr_name, configuration[:message]) unless value.to_s =~ configuration[:with]
        end
      end
    end
  end
end