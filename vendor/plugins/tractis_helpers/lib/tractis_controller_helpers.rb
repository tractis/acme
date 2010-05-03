
module TractisControllerHelpers
  def self.included(base)
    base.helper_method :respond_to
  end
private
  def render_flash
    render :update do |page|
      page.replace 'alerts', show_flash()
      yield(page) if block_given?
    end
  end
  def notify(klass=:notice, title=nil, msgs=[])
    flash[klass] ||= []
    flash[klass]  << {:title => title, :msgs => [msgs].flatten}
  end
  
  def notify_errors(object, message=nil)
    object.errors.each do |key, value|
      text = (value % {:fn => key}).capitalize
      notify :error, message || _('Acction not performed'), [_(text)]
      return
    end
  end
end