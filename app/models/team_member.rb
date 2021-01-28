# frozen_string_literal: true

require "dao/team_member"

# class TeamMember
class TeamMember < Model
  attr_reader :security_level
  attr_reader :team
  attr_reader :person

  ROLE_ADMIN = :admin.freeze
  ROLE_CHAIR = :chair.freeze
  ROLE_MEMBER = :member.freeze

  ROLE = {
      ROLE_ADMIN => "admin",
      ROLE_CHAIR => "chair",
      ROLE_MEMBER => "member"
  }.freeze

  PRIVILEGES_DEFAULT_MASK = 0.freeze
  PRIVILEGES_DELETE_MASK = 1.freeze
  PRIVILEGES_NOMINATE_MASK = 2.freeze

  MAX_DOCUMENTS = 5.freeze
  MAX_CHAIR_DOCUMENTS = 10.freeze

  NOMINATIONS_TIME_PERIOD = 30.freeze

  private_constant :ROLE_ADMIN, :ROLE_CHAIR, :ROLE_MEMBER, :ROLE,
                   :PRIVILEGES_DEFAULT_MASK, :PRIVILEGES_DELETE_MASK, :PRIVILEGES_NOMINATE_MASK,
                   :MAX_DOCUMENTS, :MAX_CHAIR_DOCUMENTS, :NOMINATIONS_TIME_PERIOD

  # CLASS - CONSTANTS

  def self.dao_class
    DAO::TeamMember
  end

  # INITIALIZATION

  def initialize(a_person, a_team)
    super()
    make_member
    @security_level = SecurityLevel.new
    do_set_nominations([])
    add_team(a_team)
    begin
      add_person(a_person)
    rescue BusinessRuleError => e
      team.do_remove_team_member(self)
      raise(e)
    end
  end

  # ACCESSING

  def name
    person&.name
  end

  def title
    person&.title
  end

  def email
    person&.email
  end

  def set_role_admin
    do_set_role(ROLE_ADMIN)
  end

  def set_role_chair
    test_set_role_chair
    do_set_role(ROLE_CHAIR)
  end

  def set_role_member
    do_set_role(ROLE_MEMBER)
  end

  def is_role_admin?
    do_get_role == ROLE_ADMIN
  end

  def is_role_chair?
    do_get_role == ROLE_CHAIR
  end

  def is_role_member?
    do_get_role == ROLE_MEMBER
  end

  def role_type
    ROLE[do_get_role]
  end

  def max_nominations_allowed
    is_role_chair? ? MAX_CHAIR_DOCUMENTS : MAX_DOCUMENTS
  end

  #ACCESSING - RULES

  def test_set_role_chair
    return if is_role_chair?
    team&.test_can_be_chair(self)
  end

  # COLLABORATION - ACCESSING

  def add_team(a_team)
    if a_team.nil?
      raise(BusinessRuleError, "Team cannot be nil")
    end
    test_team_species(a_team)
    test_add_team(a_team)
    a_team.test_add_team_member(self)
    do_add_team(a_team)
    a_team.do_add_team_member(self)
  end

  def add_person(a_person)
    if a_person.nil?
      raise(BusinessRuleError, "Person cannot be nil")
    end
    test_person_species(a_person)
    test_add_person(a_person)
    a_person.test_add_team_member(self)
    do_add_person(a_person)
    a_person.do_add_team_member(self)
  end

  def nominations
    @nominations ||= @dao.model_nominations
  end

  # COLLABORATION - RULES

  def test_team_species(a_team)
    unless a_team.species?(:Team)
      raise(BusinessRuleError, "Team is wrong type")
    end
  end

  def test_add_team(a_team)
    if team.present?
      raise(BusinessRuleError, "Team member already has a team")
    end
    unless person.nil?
      test_add_conflict_between(person, a_team)
    end
  end

  def test_person_species(a_person)
    unless a_person.species?(:Person)
      raise(BusinessRuleError, "Person is wrong type")
    end
  end

  def test_add_person(a_person)
    if person.present?
      raise(BusinessRuleError, "Team member already has a person")
    end
    unless a_person.has_valid_email?
      raise(BusinessRuleError, "Tried to add person with invalid email")
    end
    unless team.nil?
      test_add_conflict_between(a_person, team)
    end
  end

  def test_add_conflict_between(a_person, a_team)
    if a_team.team_member_for(a_person).present?
      raise(BusinessRuleError, "Tried to add person twice to team")
    end
  end

  def test_add_nomination(a_nomination)
    unless has_nominate_privilege?
      raise(BusinessRuleError, "Team member does not have nomination privilege")
    end
    if count_nominations_per_period >= max_nominations_allowed
      raise(BusinessRuleError, "Team member cannot nominate. Too many nominations")
    end
  end

  # COLLABORATION - AUTHORIZED OBJECTS ONLY

  def do_add_team(a_team)
    @team = a_team
  end

  def do_add_person(a_person)
    @person = a_person
  end

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
    {id: id, role: role_type, security_level: security_level.level, team_id: team.id, person_id: person.id}.as_json
  end

  # PREDICATES

  def has_valid_email?
    person&.has_valid_email?
  end

  def has_delete_privilege?
    (do_get_privileges & PRIVILEGES_DELETE_MASK) != 0
  end

  def has_nominate_privilege?
    (do_get_privileges & PRIVILEGES_NOMINATE_MASK) != 0
  end

  # COMPARING

  def hash
    [do_get_role, do_get_privileges, security_level, team, person].hash
  end

  # PRINTING

  def to_s
    "TeamMember-#{role_type}:#{security_level}"
  end

  # BUSINESS SERVICES

  def make_admin
    set_role_admin
    grant_nominate_privilege
    revoke_delete_privilege
  end

  def make_chair
    set_role_chair
    grant_nominate_privilege
    grant_delete_privilege
  end

  def make_member
    set_role_member
    do_set_privileges(PRIVILEGES_DEFAULT_MASK)
  end

  def grant_delete_privilege
    do_set_privileges(do_get_privileges | PRIVILEGES_DELETE_MASK)
  end

  def grant_nominate_privilege
    do_set_privileges(do_get_privileges | PRIVILEGES_NOMINATE_MASK)
  end

  def revoke_delete_privilege
    return unless has_delete_privilege?
    do_set_privileges(do_get_privileges ^ PRIVILEGES_DELETE_MASK)
  end

  def revoke_nominate_privilege
    return unless has_delete_privilege?
    do_set_privileges(do_get_privileges ^ PRIVILEGES_NOMINATE_MASK)
  end

  def count_nominations_per_days(the_number_of_days)
    return 0 if nominations.empty?
    an_end_date = Date.today - the_number_of_days
    nominations.sum { |a_nomination| a_nomination.nomination_date > an_end_date ? 1 : 0 }
  end

  def count_nominations_per_period
    count_nominations_per_days(NOMINATIONS_TIME_PERIOD)
  end

  # CLASS - SAMPLE OBJECTS

  unless Rails.env.production?
    def self.sample_admin
      test_team = Team.sample_no_chair_team
      test_team.save! unless test_team.persisted?
      test_person = Person.sample_person_alfred_with_email
      test_person.save! unless test_person.persisted?
      sample_object = self.find_by(team_id: test_team.id, person_id: test_person.id)
      return sample_object if sample_object.present?
      sample_object = self.new(test_person, test_team)
      sample_object.make_admin
      sample_object
    end

    def self.sample_chair
      test_team = Team.sample_team
      test_team.save! unless test_team.persisted?
      test_person = Person.sample_person_alfred_with_email
      test_person.save! unless test_person.persisted?
      sample_object = self.find_by(team_id: test_team.id, person_id: test_person.id)
      return sample_object if sample_object.present?
      sample_object = self.new(test_person, test_team)
      sample_object.make_chair
      sample_object.security_level.set_level_high
      sample_object
    end

    def self.sample_no_nominate
      test_team = Team.sample_team
      test_team.save! unless test_team.persisted?
      test_person = Person.sample_person_alfred_with_email
      test_person.save! unless test_person.persisted?
      sample_object = self.find_by(team_id: test_team.id, person_id: test_person.id)
      return sample_object if sample_object.present?
      sample_object = self.new(test_person, test_team)
      sample_object.revoke_nominate_privilege
      sample_object
    end

    def self.sample_secret
      test_team = Team.sample_single_chair_team
      test_team.save! unless test_team.persisted?
      test_person = Person.sample_person_tony_with_email
      test_person.save! unless test_person.persisted?
      sample_object = self.find_by(team_id: test_team.id, person_id: test_person.id)
      return sample_object if sample_object.present?
      sample_object = self.new(test_person, test_team)
      sample_object.grant_nominate_privilege
      sample_object.security_level.set_level_secret
      sample_object
    end
  end

  private

  # ACCESSING - PRIVATE

  def do_get_privileges
    @privileges
  end

  def do_set_privileges(a_privilege_mask)
    @privileges = a_privilege_mask
  end

  def do_get_role
    @role
  end

  def do_set_role(a_role)
    @role = a_role
  end

  def do_set_nominations(a_collection)
    @nominations = a_collection
  end

  # ERADICATION - PRIVATE

  def do_eradicate
    super
    person.do_remove_team_member(self)
    team.do_remove_team_member(self)
  end

  # PREDICATES - PRIVATE

  def constructed?
    return false unless team.present?
    return false unless person.present?
    true
  end

  # SAVING - PRIVATE

  def initialize_from_dao
    super
    @role = @dao.role.to_sym
    @privileges = @dao.privileges
    @security_level = SecurityLevel.from_code(@dao.security_level)
    @team = @dao.team.model
    @person = @dao.person.model
    @nominations = nil # set to nil for lazy load
  end

  def save_to_dao
    super
    @dao.role = @role
    @dao.privileges = @privileges
    @dao.security_level = @security_level.code
    @dao.team = @team.my_dao
    @dao.person = @person.my_dao
  end
end
