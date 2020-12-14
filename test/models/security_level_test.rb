require "test_helper"

class SecurityLevelTest < MiniTest::Unit::TestCase
  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test
    skip 'Not implemented'
  end

  def test_good_default_construction
    a_security_level = SecurityLevel.new
    assert(a_security_level.is_level_low?)
  end

  def test_good_construction_with_code
    a_security_level = SecurityLevel.from_code(0)
    assert(a_security_level.is_level_low?)
  end

  def test_non_integer_construction_with_code
    assert_raises(BusinessRuleError) { SecurityLevel.from_code("0") }
  end

  def test_invalid_construction_with_code
    assert_raises(BusinessRuleError) { SecurityLevel.from_code(100) }
  end

  def test_low_security_level
    a_security_level = SecurityLevel.new
    a_security_level.set_level_low
    assert(a_security_level.is_level_low?)
  end

  def test_medium_security_level
    a_security_level = SecurityLevel.new
    a_security_level.set_level_medium
    assert(a_security_level.is_level_medium?)
  end

  def test_high_security_level
    a_security_level = SecurityLevel.new
    a_security_level.set_level_high
    assert(a_security_level.is_level_high?)
  end

  def test_secret_security_level
    a_security_level = SecurityLevel.new
    a_security_level.set_level_secret
    assert(a_security_level.is_level_secret?)
  end

  def test_equal_security_levels
    a_security_level = SecurityLevel.new
    b_security_level = SecurityLevel.new
    assert(a_security_level == b_security_level)
  end

  def test_hashes_for_security_levels
    a_security_level = SecurityLevel.new
    b_security_level = SecurityLevel.new
    assert(a_security_level.hash == b_security_level.hash)
  end

  def test_comparable_security_levels
    a_security_level = SecurityLevel.new
    b_security_level = SecurityLevel.new
    b_security_level.set_level_secret
    assert(a_security_level < b_security_level)
    refute(a_security_level > b_security_level)
    refute(a_security_level == b_security_level)
  end
end