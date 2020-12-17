# frozen_string_literal: true

require "dao/nomination"

# class Nomination
class Nomination < Model
  attr_reader :comments
  attr_reader :nomination_date
  attr_reader :team_member
  attr_reader :nominatable

  STATUS_APPROVED = :approved.freeze
  STATUS_IN_REVIEW = :in_review.freeze
  STATUS_PENDING = :pending.freeze
  STATUS_REJECTED = :rejected.freeze

  STATUS = {
      STATUS_APPROVED => "Approved",
      STATUS_IN_REVIEW => "In Review",
      STATUS_PENDING => "Pending",
      STATUS_REJECTED => "Rejected"
  }.freeze

  private_constant :STATUS_APPROVED, :STATUS_IN_REVIEW, :STATUS_PENDING, :STATUS_REJECTED

  # CLASS - CONSTANTS

  def self.dao_class
    DAO::Nomination
  end

  # INITIALIZATION

  def initialize(a_team_member, a_nominatable)
    super()
    do_set_comments("")
    set_status_pending
    @nomination_date = Date.today
    add_team_member(a_team_member)
    begin
      add_nominatable(a_nominatable)
    rescue BusinessRuleError => e
      a_team_member.do_remove_nomination(self)
      raise(e)
    end
  end

  # ACCESSING

  def comments=(a_string)
    the_comments = a_string.to_s.strip
    return if self.comments == the_comments
    test_set_comments(the_comments)
    do_set_comments(the_comments)
  end

  def set_status_approved
    do_set_status(STATUS_APPROVED)
  end

  def set_status_in_review
    do_set_status(STATUS_IN_REVIEW)
  end

  def set_status_pending
    do_set_status(STATUS_PENDING)
  end

  def set_status_rejected
    do_set_status(STATUS_REJECTED)
  end

  def is_status_approved?
    do_get_status == STATUS_APPROVED
  end

  def is_status_in_review?
    do_get_status == STATUS_IN_REVIEW
  end

  def is_status_pending?
    do_get_status == STATUS_PENDING
  end

  def is_status_rejected?
    do_get_status == STATUS_REJECTED
  end

  def status_type
    STATUS[do_get_status]
  end

  #ACCESSING - RULES

  def test_set_comments(the_comments)
    # this space reserved for future use
  end

  # COLLABORATION - ACCESSING

  def add_team_member(a_team_member)
    test_add_team_member(a_team_member)
    a_team_member.test_add_nomination(self)
    do_add_team_member(a_team_member)
    a_team_member.do_add_nomination(self)
  end

  def add_nominatable(a_nominatable)
    test_add_nominatable(a_nominatable)
    a_nominatable.test_add_nomination(self)
    do_add_nominatable(a_nominatable)
    a_nominatable.do_add_nomination(self)
  end

  # COLLABORATION - RULES

  def test_add_team_member(a_team_member)
    if a_team_member.nil?
      raise(BusinessRuleError, "Team Member cannot be nil")
    end
    if team_member.present?
      raise(BusinessRuleError, "Team member already exists")
    end
    unless nominatable.nil?
      nominatable.test_add_team_member_conflict(a_team_member)
    end
  end

  def test_add_nominatable(a_nominatable)
    if a_nominatable.nil?
      raise(BusinessRuleError, "Nominatable cannot be nil")
    end
    if nominatable.present?
      raise(BusinessRuleError, "Nominatable already exists")
    end
    unless team_member.nil?
      a_nominatable.test_add_team_member_conflict(team_member)
    end
  end

  # COLLABORATION - AUTHORIZED OBJECTS ONLY

  def do_add_team_member(a_team_member)
    @team_member = a_team_member
  end

  def do_add_nominatable(a_nominatable)
    @nominatable = a_nominatable
  end

  # ERADICATION - RULES

  def eradication_issues(the_issues)
    super(the_issues)
    unless is_status_not_resolved?
      the_issues << "nomination already #{is_status_approved? ? "approved" : "rejected"}"
    end
  end

  # CONVERSION

  def as_json(options = nil)
    {id: id, status: status_type, nomination_date: nomination_date, comments: comments, team_member_id: team_member.id, nominatable_id: nominatable.id, nominatable_type: nominatable.class.to_s}.as_json
  end

  # PREDICATES

  def is_before?(a_date)
    nomination_date < a_date
  end

  def is_after?(a_date)
    a_date < nomination_date
  end

  def is_status_not_resolved?
    is_status_pending? || is_status_in_review?
  end

  # COMPARING

  def hash
    [do_get_status, nomination_date, comments, team_member, nominatable].hash
  end

  # PRINTING

  def to_s
    "Nomination-#{status_type}:#{nomination_date}"
  end

  # BUSINESS SERVICES

  # CLASS - SAMPLE OBJECTS

  unless Rails.env.production?
    def self.sample_document_nomination
      a_document = Document.sample_normal
      a_document.save! unless a_document.persisted?
      a_team_member = TeamMember.sample_chair
      a_team_member.save! unless a_team_member.persisted?
      sample_object = self.find_by(nominatable_id: a_document.id, nominatable_type: a_document.dao_class.to_s, team_member_id: a_team_member.id)
      return sample_object if sample_object.present?
      a_document.nominate(a_team_member)
    end

    def self.sample_project_nomination
      a_project = Project.sample_normal
      a_project.save! unless a_project.persisted?
      a_team_member = TeamMember.sample_chair
      a_team_member.save! unless a_team_member.persisted?
      sample_object = self.find_by(nominatable_id: a_project.id, nominatable_type: a_project.dao_class.to_s, team_member_id: a_team_member.id)
      return sample_object if sample_object.present?
      a_project.nominate(a_team_member)
    end
  end

  private

  # ACCESSING - PRIVATE

  def do_set_comments(the_comments)
    @comments = the_comments
  end

  def do_get_status
    @status
  end

  def do_set_status(a_status)
    @status = a_status
  end

  # ERADICATION - PRIVATE

  def do_eradicate
    super
    nominatable.do_remove_nomination(self)
    team_member.do_remove_nomination(self)
  end

  # PREDICATES - PRIVATE

  def constructed?
    return false unless team_member.present?
    return false unless nominatable.present?
    true
  end

  # SAVING - PRIVATE

  def initialize_from_dao
    super
    @status = @dao.status.to_sym
    @nomination_date = @dao.nomination_date
    @comments = @dao.comments
    @team_member = @dao.team_member.model
    @nominatable = @dao.nominatable.model
  end

  def save_to_dao
    super
    @dao.status = @status
    @dao.nomination_date = @nomination_date
    @dao.comments = @comments
    @dao.team_member = @team_member.my_dao
    @dao.nominatable = @nominatable.my_dao
  end
end
