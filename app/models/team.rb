# frozen_string_literal: true

require "dao/team"

# class Team
class Team < Model
  attr_reader :description

  FORMAT_NO_CHAIR = :none.freeze
  FORMAT_SINGLE_CHAIR = :single.freeze
  FORMAT_MULTIPLE_CHAIR = :multiple.freeze

  TEAM_FORMAT = {
      FORMAT_NO_CHAIR => "no chairs",
      FORMAT_SINGLE_CHAIR => "single chair",
      FORMAT_MULTIPLE_CHAIR => "multiple chairs"
  }.freeze

  private_constant :FORMAT_NO_CHAIR, :FORMAT_SINGLE_CHAIR, :FORMAT_MULTIPLE_CHAIR, :TEAM_FORMAT

  # CLASS - CONSTANTS

  def self.dao_class
    DAO::Team
  end

  # INITIALIZATION

  def initialize
    super()
    do_set_description("")
    set_format_multiple_chair
    do_set_team_members([])
  end

  # ACCESSING

  def description=(a_string)
    a_description = a_string.to_s.strip
    return if self.description == a_description
    test_set_description(a_description)
    do_set_description(a_description)
  end

  def set_format_no_chair
    do_set_format_style(FORMAT_NO_CHAIR)
  end

  def set_format_single_chair
    do_set_format_style(FORMAT_SINGLE_CHAIR)
  end

  def set_format_multiple_chair
    do_set_format_style(FORMAT_MULTIPLE_CHAIR)
  end

  def is_format_no_chair?
    do_get_format_style == FORMAT_NO_CHAIR
  end

  def is_format_single_chair?
    do_get_format_style == FORMAT_SINGLE_CHAIR
  end

  def is_format_multiple_chair?
    do_get_format_style == FORMAT_MULTIPLE_CHAIR
  end

  def format_style_type
    TEAM_FORMAT[do_get_format_style]
  end

  # ACCESSING - RULES

  def test_set_description(a_description)
    # this space reserved for future use
  end

  # COLLABORATION - ACCESSING

  def team_members
    @team_members ||= @dao.model_team_members
  end

  def chairs
    team_members.select { |a_team_member| a_team_member.is_role_chair? }
  end

  def team_member_for(a_person)
    team_members.detect { |a_team_member| a_team_member.person == a_person }
  end

  # COLLABORATION - RULES

  def test_add_team_member(a_team_member)
    if a_team_member.is_role_chair?
      test_can_be_chair(a_team_member)
    end
  end

  def test_can_be_chair(a_team_member)
    return if is_format_multiple_chair?
    if is_format_no_chair?
      raise(BusinessRuleError, "Tried to add chair team member to no chairs team")
    end
    if chairs.size == 1
      raise(BusinessRuleError, "Tried to add another chair team member to a single chair team")
    end
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
    {id: id, description: description, format_style_type: format_style_type}.as_json
  end

  # PREDICATES

  # COMPARING

  def hash
    [description, do_get_format_style].hash
  end

  # PRINTING

  def to_s
    "Team-#{description}:#{format_style_type}"
  end

  # BUSINESS SERVICES

  # CLASS - SAMPLE OBJECTS

  unless Rails.env.production?
    def self.sample_team
      sample_object = self.find_by(description: "System Integration Team")
      return sample_object if sample_object.present?
      sample_object = self.new
      sample_object.description = "System Integration Team"
      sample_object
    end

    def self.sample_no_chair_team
      sample_object = self.find_by(description: "Summer Picnic Planning Team")
      return sample_object if sample_object.present?
      sample_object = self.new
      sample_object.description = "Summer Picnic Planning Team"
      sample_object.set_format_no_chair
      sample_object
    end

    def self.sample_single_chair_team
      sample_object = self.find_by(description: "Executive Strategy Team")
      return sample_object if sample_object.present?
      sample_object = self.new
      sample_object.description = "Executive Strategy Team"
      sample_object.set_format_single_chair
      sample_object
    end
  end

  private

  # ACCESSING - PRIVATE

  def do_set_description(a_description)
    @description = a_description
  end

  def do_set_team_members(a_collection)
    @team_members = a_collection
  end

  def do_get_format_style
    @format_style
  end

  def do_set_format_style(a_format_style)
    @format_style = a_format_style
  end

  # PREDICATES - PRIVATE

  def constructed?
    true
  end

  # SAVING - PRIVATE

  def initialize_from_dao
    super
    @description = @dao.description
    @format_style = @dao.format_style.to_sym
    @team_members = nil # set to nil for lazy load
  end

  def save_to_dao
    super
    @dao.description = description
    @dao.format_style = @format_style
  end
end
