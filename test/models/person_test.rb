require "test_helper"

class PersonTest < MiniTest::Unit::TestCase
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
    assert(a_person.persisted?)
    z_person = Person.find(a_person.id)
    assert(z_person.present?)
    assert_equal(a_person.name, z_person.name)
    assert_equal(a_person.title, z_person.title)
    assert_equal(a_person.email, z_person.email)
    assert_equal(a_person.class_name, "Person")
    refute_empty(Person.all)
  end

  def test_nil_name_on_construction
    assert_raises(BusinessRuleError) { Person.new(nil) }
  end

  def test_empty_name_on_construction
    assert_raises(BusinessRuleError) { Person.new("") }
  end

  def test_just_spaces_name_on_construction
    assert_raises(BusinessRuleError) { Person.new("   ") }
  end

  def test_nil_name_on_rename
    a_person = Person.sample_person_alfred_with_email
    assert_raises(BusinessRuleError) { a_person.name = nil }
  end

  def test_empty_name_on_rename
    a_person = Person.sample_person_alfred_with_email
    assert_raises(BusinessRuleError) { a_person.name = "" }
  end

  def test_just_spaces_name_on_rename
    a_person = Person.sample_person_alfred_with_email
    assert_raises(BusinessRuleError) { a_person.name = "   " }
  end

  def test_valid_email
    a_person = Person.sample_person_tony_without_email
    a_person.email = "tony@tiger.com"
    assert_equal("tony@tiger.com", a_person.email)
  end

  def test_invalid_email
    a_person = Person.sample_person_tony_without_email
    assert_raises(BusinessRuleError) { a_person.email = "tony.tiger.com" }
  end

  def test_valid_removing_email
    a_person = Person.sample_person_alfred_with_email
    a_person.remove_email
    refute(a_person.has_valid_email?)
  end

  def test_removing_email_with_nil
    a_person = Person.sample_person_alfred_with_email
    assert_raises(BusinessRuleError) { a_person.email = nil }
  end

  def test_removing_email_with_empty_string
    a_person = Person.sample_person_alfred_with_email
    assert_raises(BusinessRuleError) { a_person.email = "" }
  end

  def test_removing_email_with_spaces
    a_person = Person.sample_person_alfred_with_email
    assert_raises(BusinessRuleError) { a_person.email = "   " }
  end

  def test_duplicate_email
    a_person = Person.sample_person_alfred_with_email
    a_person.save!
    another_person = Person.sample_person_tony_without_email
    assert_raises(BusinessRuleError) { another_person.email = a_person.email }
  end

  def test_getting_team_members
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_person = a_team_member.person
    a_person.reload
    refute_empty(a_person.team_members)
  end

  def test_finding_team_member
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_person = a_team_member.person
    a_team = a_team_member.team
    z_team_member = a_person.team_member_for(a_team)
    assert(a_team_member == z_team_member)
  end

  def test_good_eradication
    a_person = Person.sample_person_alfred_with_email
    a_person.save!
    a_person.eradicate
    assert_raises(BusinessRuleError) { a_person.save! }
  end

  def test_eradication_with_team_members
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_person = a_team_member.person
    assert_raises(BusinessRuleError) { a_person.eradicate }
  end

  def test_equals
    a_person = Person.sample_person_alfred_with_email
    z_person = Person.sample_person_tony_without_email
    assert(a_person == a_person)
    refute(a_person.eql?(z_person))
  end

  def test_to_s
    a_person = Person.sample_person_alfred_with_email
    assert_match(/Person/, a_person.to_s)
  end

  def test_as_json
    a_person = Person.sample_person_alfred_with_email
    a_person.save!
    refute_empty(a_person.as_json)
  end

end