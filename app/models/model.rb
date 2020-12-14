# frozen_string_literal: true

require "dao/model"

# class Model
class Model
  # CLASS - CONSTANTS

  def self.dao_class
    raise(NotImplementedError, "#{self.class.name}#dao_class is an abstract class method")
  end

  # CLASS - BUSINESS SERVICES

  def self.find(id)
    find_by(id: id) || raise(BusinessRuleError, "#{self.name} id: #{id} not found")
  end

  def self.find_by(*args)
    dao = dao_class.find_by(*args)
    dao.present? ? dao.model : nil
  end

  def self.all
    dao_class.all.to_a.collect(&:model)
  end

  # INITIALIZATION

  def initialize
    @dao = nil
  end

  def establish_dao(a_dao)
    raise(BusinessRuleError, "Data Access Object is nil") if a_dao.nil?
    raise(BusinessRuleError, "Data Access Object already set") if @dao.present?
    raise(BusinessRuleError, "Data Access Object wrong type") unless a_dao.class == dao_class
    @dao = a_dao
    @dao.model = self
    initialize_from_dao
    self
  end

  def reload
    initialize_from_dao unless @dao.nil?
    self
  end

  # ACCESSING

  def class_name
    self.class.name.split("::").last
  end

  def my_dao
    @dao
  end

  def id
    @dao&.id
  end

  # ACCESSING - CONSTANTS

  def dao_class
    self.class.dao_class
  end

  # COLLABORATION - ACCESSING

  def parent
    nil
  end

  # ERADICATION

  def eradicate
    test_eradicate
    do_eradicate
  end

  # ERADICATION - RULES

  def test_eradicate
    issues = []
    eradication_issues(issues)
    if issues.any?
      raise(BusinessRuleError, "Cannot eradicate: #{issues.join(", ")}")
    end
  end

  def eradication_issues(the_issues)
    # this space reserved for future use
  end

  # CONVERSION

  def as_json(options = nil)
    raise(NotImplementedError, "#{self.class.name}#as_json is an abstract model method")
  end

  # PREDICATES

  def persisted?
    return false if @dao.nil?
    @dao.persisted?
  end

  # COMPARING

  def ==(other)
    return false unless other.is_a?(self.class)
    hash == other.hash
  end

  def eql?(other)
    self == other
  end

  def hash
    raise(NotImplementedError, "#{self.class.name}#hash is an abstract model method")
  end

  # PRINTING

  def to_s
    raise(NotImplementedError, "#{self.class.name}#to_s is an abstract model method")
  end

  # SAVING

  def save!
    if @dao.nil?
      @dao = dao_class.new
      @dao.model = self
    end
    begin
      save_to_dao
    rescue FrozenError
      raise(BusinessRuleError, "Model object has been eradicated")
    end
    @dao.save!
  end

  private

  # ERADICATION - PRIVATE

  def do_eradicate
    @dao&.destroy
    # need to think about what else should happen on eradication
  end

  # PREDICATES - PRIVATE

  def constructed?
    raise(NotImplementedError, "#{self.class.name}#constructed? is a private abstract model method")
  end

  # SAVING - PRIVATE

  def initialize_from_dao
    # this space reserved for future use
  end

  def save_to_dao
    # this space reserved for future use
  end
end
