require "test_helper"

class TeamMemberTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test
    skip 'Not implemented'
  end

  def test_good_construction_and_save
    a_person = Person.sample_person_alfred_with_email
    a_person.save!
    a_team = Team.sample_single_chair_team
    a_team.save!
    a_team_member = TeamMember.new(a_person, a_team)
    a_team_member.save!
    a_team_member.reload
    assert(a_team_member.persisted?)
    assert(a_team_member.is_role_member?)
    assert(a_team_member.has_valid_email?)
    refute(a_team_member.has_nominate_privilege?)
    refute(a_team_member.has_delete_privilege?)
    assert_equal(a_team_member.class_name, "TeamMember")
    refute_empty(TeamMember.all)
  end

  def test_duplicate_construction_with_same_person_and_team
    a_person = Person.sample_person_alfred_with_email
    a_person.save!
    a_team = Team.sample_single_chair_team
    a_team.save!
    a_team_member = TeamMember.new(a_person, a_team)
    a_team_member.save!
    assert_raises(BusinessRuleError) { TeamMember.new(a_person, a_team) }
  end

  def test_bad_construction_with_nil_person
    a_team = Team.sample_single_chair_team
    a_team.save!
    assert_raises(BusinessRuleError) { TeamMember.new(nil, a_team) }
  end

  def test_bad_construction_with_nil_team
    a_person = Person.sample_person_alfred_with_email
    a_person.save!
    assert_raises(BusinessRuleError) { TeamMember.new(a_person, nil) }
  end

  def test_bad_construction_with_person_without_email
    a_person = Person.sample_person_tony_without_email
    a_person.save!
    a_team = Team.sample_single_chair_team
    a_team.save!
    assert_raises(BusinessRuleError) { TeamMember.new(a_person, a_team) }
  end

  def test_adding_person_to_existing_team_member
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_person = Person.sample_person_tony_without_email
    a_person.email = "tony@tiger.com"
    a_person.save!
    assert_raises(BusinessRuleError) { a_team_member.add_person(a_person) }
  end

  def test_adding_team_to_existing_team_member
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_team = Team.sample_no_chair_team
    a_team.save!
    assert_raises(BusinessRuleError) { a_team_member.add_team(a_team) }
  end

  def test_object_inheritance_from_person
    a_team_member = TeamMember.sample_chair
    a_person = a_team_member.person
    assert_equal(a_team_member.name, a_person.name)
    assert_equal(a_team_member.title, a_person.title)
    assert_equal(a_team_member.email, a_person.email)
    assert_equal(a_team_member.has_valid_email?, a_person.has_valid_email?)
  end

  def test_getting_nominations
    a_nomination = Nomination.sample_document_nomination
    a_nomination.save!
    a_team_member = a_nomination.team_member
    a_team_member.reload
    refute_empty(a_team_member.nominations)
  end

  def test_good_eradication
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_team_member.eradicate
    assert_raises(BusinessRuleError) { a_team_member.save! }
    a_person = a_team_member.person
    a_team = a_team_member.team
    refute(a_team.team_member_for(a_person))
    a_person.reload
    a_team.reload
    refute(a_team.team_member_for(a_person))
  end

  def test_eradication_with_nominations
    a_nomination = Nomination.sample_document_nomination
    a_nomination.save!
    a_team_member = a_nomination.team_member
    assert_raises(BusinessRuleError) { a_team_member.eradicate }
  end

  def test_making_team_member_chair_on_team_without_chairs
    a_team = Team.sample_no_chair_team
    a_team.save!
    a_person = Person.sample_person_alfred_with_email
    a_person.save!
    a_team_member = TeamMember.new(a_person, a_team)
    a_team_member.save!
    assert_raises(BusinessRuleError) { a_team_member.make_chair }
  end

  def test_roles_and_privileges
    a_team_member = TeamMember.sample_chair
    a_team_member.make_chair
    assert(a_team_member.is_role_chair?)
    assert(a_team_member.has_nominate_privilege?)
    assert(a_team_member.has_delete_privilege?)
    a_team_member.make_member
    assert(a_team_member.is_role_member?)
    refute(a_team_member.has_nominate_privilege?)
    refute(a_team_member.has_delete_privilege?)
    a_team_member.make_admin
    assert(a_team_member.is_role_admin?)
    assert(a_team_member.has_nominate_privilege?)
    refute(a_team_member.has_delete_privilege?)
  end

  def test_revoking_privileges
    a_team_member = TeamMember.sample_chair
    assert(a_team_member.has_nominate_privilege?)
    assert(a_team_member.has_delete_privilege?)
    a_team_member.revoke_nominate_privilege
    a_team_member.revoke_delete_privilege
    refute(a_team_member.has_nominate_privilege?)
    refute(a_team_member.has_delete_privilege?)
  end

  def test_max_nominations
    a_team_member = TeamMember.sample_no_nominate
    a_team_member.grant_nominate_privilege
    a_team_member.save!
    5.times do |i|
      a_document = Document.new("Document #{i}")
      a_document.save!
      a_nomination = a_document.nominate(a_team_member)
      a_nomination.save!
    end
    assert(a_team_member.nominations.size == 5)
    a_document = Document.new("Document 6")
    a_document.save!
    assert_raises(BusinessRuleError) { a_document.nominate(a_team_member) }
  end

  def test_max_chair_nominations
    a_team_member = TeamMember.sample_chair
    a_team_member.grant_nominate_privilege
    a_team_member.save!
    10.times do |i|
      a_document = Document.new("Document #{i}")
      a_document.save!
      a_nomination = a_document.nominate(a_team_member)
      a_nomination.save!
    end
    assert(a_team_member.nominations.size == 10)
    a_document = Document.new("Document 11")
    a_document.save!
    assert_raises(BusinessRuleError) { a_document.nominate(a_team_member) }
  end

  def test_no_nomination_privilege
    a_team_member = TeamMember.sample_no_nominate
    a_team_member.save!
    a_document = Document.sample_normal
    a_document.save!
    assert_raises(BusinessRuleError) { a_document.nominate(a_team_member) }
  end

  def test_equals
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_person = a_team_member.person
    a_team = Team.sample_single_chair_team
    a_team.save!
    z_team_member = TeamMember.new(a_person, a_team)
    z_team_member.save!
    assert(a_team_member == a_team_member)
    refute(a_team_member.eql?(z_team_member))
  end

  def test_to_s
    a_team_member = TeamMember.sample_chair
    assert_match(/TeamMember/, a_team_member.to_s)
  end

  def test_as_json
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    refute_empty(a_team_member.as_json)
  end

end