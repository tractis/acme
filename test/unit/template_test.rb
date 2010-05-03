require File.dirname(__FILE__) + '/../test_helper'

class TemplateTest < Test::Unit::TestCase
  def setup
    #Tractis.config('ernesto.jimenez@negonation.com', '12341234', 'http://0.0.0.0:3001')
  end
  
  def test_find_all
    list = Template.find(:all)
    assert_equal(Array, list.class)
  end
  
  def test_find_first
    first = Template.find(:first)
    assert_equal(Hash, first.class)
  end
  
  def test_find_by_id
    first = Template.find(:first)
    by_id = Template.find(first[:id])
    assert_equal(Hash, by_id.class)
  end
  
  def test_get_variables
    first = Template.find(:first)
    vars = Template.variables(first[:id])
    assert_equal(Hash, vars.class)
  end
end