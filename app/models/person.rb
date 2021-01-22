# frozen_string_literal: true

require "dao/person"

# class Person
class Person < Model
  attr_reader :name
  attr_reader :title
  attr_reader :email

  # CLASS - CONSTANTS

  def self.dao_class
    DAO::Person
  end

  # INITIALIZATION

  def initialize(a_name)
    super()
    self.name = a_name
    do_set_title("")
    remove_email
    do_set_team_members([])
  end

  # ACCESSING

  def name=(a_string)
    a_name = a_string.to_s.strip
    return if self.name == a_name
    test_set_name(a_name)
    do_set_name(a_name)
  end

  def title=(a_string)
    a_title = a_string.to_s.strip
    return if self.title == a_title
    test_set_title(a_title)
    do_set_title(a_title)
  end

  def email=(a_string)
    an_email = a_string.to_s.strip
    return if self.email == an_email
    test_set_email(an_email)
    do_set_email(an_email)
  end

  def remove_email
    do_set_email("")
  end

  # ACCESSING - RULES

  def test_set_name(a_name)
    raise(BusinessRuleError, "Person name cannot be empty") if a_name.blank?
  end

  def test_set_title(a_title)
    # this space reserved for future use
  end

  def test_set_email(an_email)
    raise(BusinessRuleError, "Bad email address") unless URI::MailTo::EMAIL_REGEXP.match?(an_email)
    raise(BusinessRuleError, "Email address not unique") unless dao_class.email_unique?(an_email)
  end

  # COLLABORATION - ACCESSING

  def team_members
    @team_members ||= @dao.model_team_members
  end

  def team_member_for(a_team)
    team_members.detect { |a_team_member| a_team_member.team == a_team }
  end

  # COLLABORATION - RULES

  def test_add_team_member(a_team_member)
    # this space reserved for future use
  end

  # COLLABORATION - AUTHORIZED OBJECTS ONLY

  def do_add_team_member(a_team_member)
    team_members << a_team_member
  end

  def do_remove_team_member(a_team_member)
    team_members.delete(a_team_member)
  end

  # ERADICATION - RULES

  def eradication_issues(the_issues)
    super(the_issues)
    unless team_members.empty?
      the_issues << "contains team members"
    end
  end

  # CONVERSION

  def as_json(options = nil)
    {id: id, name: name, title: title, email: email}.as_json
  end

  # PREDICATES

  def acts_like_person?
  end

  def has_valid_email?
    email.present?
  end

  # COMPARING

  def hash
    [name, title, email].hash
  end

  # PRINTING

  def to_s
    "Person-#{name}:#{title}:#{email}"
  end

  # BUSINESS SERVICES

  # CLASS - SAMPLE OBJECTS

  unless Rails.env.production?
    def self.sample_person_alfred_with_email
      sample_object = self.find_by(name: "Alfred E. Neumann", email: "al@neumann.com")
      return sample_object if sample_object.present?
      sample_object = self.new("Alfred E. Neumann")
      sample_object.title = "President"
      sample_object.email = "al@neumann.com"
      sample_object
    end

    def self.sample_person_tony_with_email
      sample_object = self.find_by(name: "Tony D. Tiger", email: "tony@tiger.com")
      return sample_object if sample_object.present?
      sample_object = self.new("Tony D. Tiger")
      sample_object.title = "Mascot"
      sample_object.email = "tony@tiger.com"
      sample_object
    end

    def self.sample_person_tony_without_email
      sample_object = self.find_by(name: "Tony D. Tiger", email: "")
      return sample_object if sample_object.present?
      sample_object = self.new("Tony D. Tiger")
      sample_object.title = "Mascot"
      sample_object
    end
  end

  private

  # ACCESSING - PRIVATE

  def do_set_name(a_name)
    @name = a_name
  end

  def do_set_title(a_title)
    @title = a_title
  end

  def do_set_email(an_email)
    @email = an_email
  end

  def do_set_team_members(a_collection)
    @team_members = a_collection
  end

  # PREDICATES - PRIVATE

  def constructed?
    return false unless name.present?
    true
  end

  # SAVING - PRIVATE

  def initialize_from_dao
    super
    @name = @dao.name
    @title = @dao.title
    @email = @dao.email
    @team_members = nil # set to nil for lazy load
  end

  def save_to_dao
    super
    @dao.name = name
    @dao.title = title
    @dao.email = email
  end
end
