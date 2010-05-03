require File.dirname(__FILE__) + '/../test_helper'

class ContractTest < Test::Unit::TestCase
  def setup
    #Tractis.config('ernesto.jimenez@negonation.com', '12341234', 'http://0.0.0.0:3001')
    #Tractis.config('erjica+demo@gmail.com', '12344321', 'https://www.tractis.com')
  end
  
  def test_find_all
    list = Contract.find(:all)
    assert_equal(Array, list.class)
  end
  
  def test_find_first
    first = Contract.find(:first)
    assert_equal(Hash, first.class)
  end
  
  def test_find_by_id
    first = Contract.find(:first)
    by_id = Contract.find(first[:id])
    assert_equal(Hash, by_id.class)
  end
  
  def test_contract_body_doesnt_escape_lt_gt
    first = Contract.find(:first)
  end
  
  def test_should_create_contract
    created = Contract.create(:name => 'holaaaa', :tag_list => 'hola, adios')
    assert(created, "Contract was not created")
    created = Contract.find(created)
    assert_equal('holaaaa', created.name)
  end
end