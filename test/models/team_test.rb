require "test_helper"

class TeamTest < MiniTest::Unit::TestCase
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
    a_team = Team.sample_single_chair_team
    a_team.save!
    assert(a_team.persisted?)
    z_team = Team.find(a_team.id)
    assert(z_team.present?)
    assert_equal(a_team.description, z_team.description)
    assert(z_team.is_format_single_chair?)
    assert_equal(a_team.class_name, "Team")
    refute_empty(Team.all)
  end

  def test_set_description
    a_team = Team.new
    a_team.description = "The A-Team"
    assert_equal("The A-Team", a_team.description)
  end

  def test_set_format_no_chair
    a_team = Team.new
    a_team.set_format_no_chair
    assert(a_team.is_format_no_chair?)
  end

  def test_set_format_single_chair
    a_team = Team.new
    a_team.set_format_single_chair
    assert(a_team.is_format_single_chair?)
  end

  def test_getting_team_members
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_team = a_team_member.team
    a_team.reload
    refute_empty(a_team.team_members)
  end

  def test_finding_team_member
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_person = a_team_member.person
    a_team = a_team_member.team
    z_team_member = a_team.team_member_for(a_person)
    assert(a_team_member == z_team_member)
  end

  def test_too_many_chairs
    a_team_member = TeamMember.sample_secret
    a_team_member.set_role_chair
    a_team_member.save!
    a_team = a_team_member.team
    a_team.set_format_single_chair
    a_team.save!
    a_person = Person.sample_person_alfred_with_email
    a_person.save!
    z_team_member = TeamMember.new(a_person, a_team)
    z_team_member.save!
    assert_raises(BusinessRuleError) { z_team_member.set_role_chair }
  end

  def test_good_eradication
    a_team = Team.sample_team
    a_team.save!
    a_team.eradicate
  end

  def test_eradication_with_team_members
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_team = a_team_member.team
    assert_raises(BusinessRuleError) { a_team.eradicate }
  end

  def test_equals
    a_team = Team.sample_team
    z_team = Team.sample_single_chair_team
    assert(a_team == a_team)
    refute(a_team.eql?(z_team))
  end

  def test_to_s
    a_team = Team.sample_team
    assert_match(/Team/, a_team.to_s)
  end

  def test_as_json
    a_team = Team.sample_team
    a_team.save!
    refute_empty(a_team.as_json)
  end

end