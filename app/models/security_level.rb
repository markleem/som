# frozen_string_literal: true

# class SecurityLevel
class SecurityLevel

  include Comparable

  attr_reader :code

  LOW = 0.freeze
  MEDIUM = 1.freeze
  HIGH = 2.freeze
  SECRET = 3.freeze

  LEVEL = {
      LOW => "low",
      MEDIUM => "medium",
      HIGH => "high",
      SECRET => "secret"
  }.freeze

  private_constant :LOW, :MEDIUM, :HIGH, :SECRET

  # CLASS - INSTANCE CREATION

  def self.from_code(a_code)
    a_security_level = self.new
    a_security_level.code = a_code
    a_security_level
  end

  # INITIALIZATION

  def initialize
    set_level_low
  end

  # ACCESSING

  def code=(a_code)
    return if self.code == a_code
    test_set_code(a_code)
    do_set_code(a_code)
  end

  def set_level_low
    do_set_code(LOW)
  end

  def set_level_medium
    do_set_code(MEDIUM)
  end

  def set_level_high
    do_set_code(HIGH)
  end

  def set_level_secret
    do_set_code(SECRET)
  end

  def is_level_low?
    code == LOW
  end

  def is_level_medium?
    code == MEDIUM
  end

  def is_level_high?
    code == HIGH
  end

  def is_level_secret?
    code == SECRET
  end

  def level
    LEVEL[do_get_code]
  end

  # ACCESSING - RULES

  def test_set_code(a_code)
    raise(BusinessRuleError, "Security code must be an integer") unless a_code.kind_of?(Integer)
    raise(BusinessRuleError, "Security code not valid") unless a_code.between?(LOW, SECRET)
  end

  # ACCESSING - AUTHORIZED OBJECTS ONLY

  def do_get_code
    @code
  end

  # COMPARING

  def <=>(other)
    do_get_code <=> other.do_get_code
  end

  def hash
    [do_get_code].hash
  end

  # PRINTING

  def to_s
    "SecurityLevel-#{level}"
  end

  private

  # ACCESSING - PRIVATE

  def do_set_code(a_code)
    @code = a_code
  end
end
