
class ActiveRecord::Base
  def has_permission?(user, action)
    false
  end
  
  def has_permission!(user, action)
    raise PermissionsError, _('You don\'t have permissions') unless has_permission?(user, action)
    true
  end

  def ensure_permission(user, action)
    return has_permission!(user,action)
  end
end

class Array
  def has_permission?(user, action)
    self.each do |element|
      element.has_permission?(user, action)
    end
  end

  def has_permission!(user, action)
    return has_permission?(user, action)
  end

  def ensure_permission(user, action)
    return has_permission!(user,action)
  end
end

class Class
  def has_permission?(user, action)
    self.each do |element|
      element.has_permission?(user, action)
    end
  end

  def has_permission!(user, action)
    return has_permission?(user, action)
  end

  def ensure_permission(user, action)
    return has_permission!(user,action)
  end
end