# frozen_string_literal: true

require "dao/project"

# class Project
class Project < Model
  attr_reader :title
  attr_reader :security_level

  # CLASS - CONSTANTS

  def self.dao_class
    DAO::Project
  end

  # INITIALIZATION

  def initialize(a_title)
    super()
    self.title = a_title
    @security_level = SecurityLevel.new
    do_set_nominations([])
  end

  # ACCESSING

  def title=(a_string)
    a_title = a_string.to_s.strip
    return if self.title == a_title
    test_set_title(a_title)
    do_set_title(a_title)
  end

  # ACCESSING - RULES

  def test_set_title(a_title)
    raise(BusinessRuleError, "Project cannot have blank title") if a_title.blank?
    raise(BusinessRuleError, "Project title not unique") unless dao_class.title_unique?(a_title)
  end

  # COLLABORATION - ACCESSING

  def nominations
    @nominations ||= @dao.model_nominations
  end

  def approved_nomination
    nominations.detect(-> do
      raise(BusinessRuleError, "Project has no approved nomination")
    end) { |a_nomination| a_nomination.is_status_approved? }
  end

  # COLLABORATION - RULES

  def test_add_nomination(a_nomination)
    if has_unresolved_nominations?
      raise(BusinessRuleError, "Project has unresolved nomination")
    end
  end

  def test_add_team_member_conflict(a_team_member)
    if security_level > a_team_member.security_level
      raise(BusinessRuleError, "Security violation. Team Member has improper security")
    end
  end

  # COLLABORATION - AUTHORIZED OBJECTS ONLY

  def do_add_nomination(a_nomination)
    nominations << a_nomination
  end

  def do_remove_nomination(a_nomination)
    nominations.delete(a_nomination)
  end

  # ERADICATION - RULES

  def eradication_issues(the_issues)
    super(the_issues)
    unless nominations.empty?
      the_issues << "contains nominations"
    end
  end

  # CONVERSION

  def as_json(options = nil)
    {id: id, title: title, security_level: security_level.level}.as_json
  end

  # PREDICATES

  def acts_like_nominatable?
  end

  def acts_like_project?
  end

  def has_nomination?(a_nomination)
    nominations.include?(a_nomination)
  end

  def has_unresolved_nominations?
    nominations.any? { |a_nomination| a_nomination.is_status_not_resolved? }
  end

  def is_approved?
    nominations.any? { |a_nomination| a_nomination.is_status_approved? }
  end

  # COMPARING

  def hash
    [title, security_level].hash
  end

  # PRINTING

  def to_s
    "Project-#{title}:#{security_level}"
  end

  # BUSINESS SERVICES

  def nominate(a_team_member)
    Nomination.new(a_team_member, self)
  end

  # CLASS - SAMPLE OBJECTS

  unless Rails.env.production?
    def self.sample_normal
      sample_object = self.find_by(title: "Normal Project")
      return sample_object if sample_object.present?
      self.new("Normal Project")
    end

    def self.sample_secret
      sample_object = self.find_by(title: "Food and Beverage Industry Surveillance Tools")
      return sample_object if sample_object.present?
      sample_object = self.new("Food and Beverage Industry Surveillance Tools")
      sample_object.security_level.set_level_secret
      sample_object
    end
  end

  private

  # ACCESSING - PRIVATE

  def do_set_title(a_title)
    @title = a_title
  end

  def do_set_nominations(a_collection)
    @nominations = a_collection
  end

  # PREDICATES - PRIVATE

  def constructed?
    return false unless title.present?
    true
  end

  # SAVING - PRIVATE

  def initialize_from_dao
    super
    @title = @dao.title
    @security_level = SecurityLevel.from_code(@dao.security_level)
    @nominations = nil # set to nil for lazy load
  end

  def save_to_dao
    super
    @dao.title = title
    @dao.security_level = @security_level.code
  end
end
