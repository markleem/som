require "test_helper"

class ProjectTest < MiniTest::Unit::TestCase
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
    a_project = Project.sample_normal
    a_project.save!
    assert(a_project.persisted?)
    z_project = Project.find(a_project.id)
    assert(z_project.present?)
    assert_equal(a_project.title, z_project.title)
    assert_equal(a_project.security_level, z_project.security_level)
    assert_equal(a_project.class_name, "Project")
    refute_empty(Project.all)
  end

  def test_nil_title_on_construction
    assert_raises(BusinessRuleError) { Project.new(nil) }
  end

  def test_empty_title_on_construction
    assert_raises(BusinessRuleError) { Project.new("") }
  end

  def test_just_spaces_title_on_construction
    assert_raises(BusinessRuleError) { Project.new("   ") }
  end

  def test_nil_title_on_retitle
    a_project = Project.sample_normal
    assert_raises(BusinessRuleError) { a_project.title = nil }
  end

  def test_empty_name_on_rename
    a_project = Project.sample_normal
    assert_raises(BusinessRuleError) { a_project.title = "" }
  end

  def test_just_spaces_name_on_rename
    a_project = Project.sample_normal
    assert_raises(BusinessRuleError) { a_project.title = "   " }
  end

  def test_duplicate_title
    a_project = Project.sample_normal
    a_project.save!
    another_project = Project.sample_secret
    assert_raises(BusinessRuleError) { another_project.title = a_project.title }
  end

  def test_getting_nominations
    a_nomination = Nomination.sample_project_nomination
    a_nomination.save!
    a_project = a_nomination.nominatable
    a_project.reload
    assert(a_project.has_nomination?(a_nomination))
    refute_empty(a_project.nominations)
  end

  def test_unresolved_nominations_before_publish
    a_nomination = Nomination.sample_project_nomination
    a_nomination.save!
    a_project = a_nomination.nominatable
    a_project.reload
    assert(a_project.has_unresolved_nominations?)
    a_team_member = TeamMember.sample_secret
    a_team_member.save!
    assert_raises(BusinessRuleError) { a_project.nominate(a_team_member) }
  end

 def test_security_violation_on_nomination
    a_project = Project.sample_secret
    a_project.save!
    a_team_member = TeamMember.sample_admin
    a_team_member.save!
    assert_raises(BusinessRuleError) { a_project.nominate(a_team_member) }
  end

  def test_good_eradication
    a_project = Project.sample_normal
    a_project.save!
    a_project.eradicate
  end

  def test_eradication_with_nominations
    a_nomination = Nomination.sample_project_nomination
    a_nomination.save!
    a_project = a_nomination.nominatable
    assert_raises(BusinessRuleError) { a_project.eradicate }
  end

  def test_equals
    a_project = Project.sample_normal
    z_project = Project.sample_secret
    assert(a_project == a_project)
    refute(a_project.eql?(z_project))
  end

  def test_to_s
    a_project = Project.sample_normal
    assert_match(/Project/, a_project.to_s)
  end

  def test_as_json
    a_project = Project.sample_normal
    a_project.save!
    refute_empty(a_project.as_json)
  end

end