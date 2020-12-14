require "test_helper"

class DocumentTest < MiniTest::Unit::TestCase
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
    a_document = Document.sample_normal
    a_document.save!
    assert(a_document.persisted?)
    assert(a_document.is_unpublished?)
    z_document = Document.find(a_document.id)
    assert(z_document.present?)
    assert_equal(a_document.title, z_document.title)
    assert_equal(a_document.security_level, z_document.security_level)
    assert_equal(a_document.class_name, "Document")
    refute_empty(Document.all)
  end

  def test_nil_title_on_construction
    assert_raises(BusinessRuleError) { Document.new(nil) }
  end

  def test_empty_title_on_construction
    assert_raises(BusinessRuleError) { Document.new("") }
  end

  def test_just_spaces_title_on_construction
    assert_raises(BusinessRuleError) { Document.new("   ") }
  end

  def test_nil_title_on_retitle
    a_document = Document.sample_normal
    assert_raises(BusinessRuleError) { a_document.title = nil }
  end

  def test_empty_name_on_rename
    a_document = Document.sample_normal
    assert_raises(BusinessRuleError) { a_document.title = "" }
  end

  def test_just_spaces_name_on_rename
    a_document = Document.sample_normal
    assert_raises(BusinessRuleError) { a_document.title = "   " }
  end

  def test_duplicate_title
    a_document = Document.sample_normal
    a_document.save!
    another_document = Document.sample_secret
    assert_raises(BusinessRuleError) { another_document.title = a_document.title }
  end

  def test_getting_nominations
    a_nomination = Nomination.sample_nomination
    a_nomination.save!
    a_document = a_nomination.document
    a_document.reload
    assert(a_document.has_nomination?(a_nomination))
    refute_empty(a_document.nominations)
  end

  def test_not_nominated_before_publish
    a_nomination = Nomination.sample_nomination
    a_nomination.save!
    a_document = a_nomination.document
    a_document.reload
    assert_raises(BusinessRuleError) { a_document.approved_nomination }
    assert_raises(BusinessRuleError) { a_document.publish }
  end

  def test_unresolved_nominations_before_publish
    a_nomination = Nomination.sample_nomination
    a_nomination.save!
    a_document = a_nomination.document
    a_document.reload
    assert(a_document.has_unresolved_nominations?)
    a_team_member = TeamMember.sample_secret
    a_team_member.save!
    assert_raises(BusinessRuleError) { a_document.nominate(a_team_member) }
  end

  def test_good_publish
    a_nomination = Nomination.sample_nomination
    a_nomination.save!
    a_document = a_nomination.document
    a_document.reload
    assert(a_document.is_unpublished?)
    a_nomination.set_status_approved
    a_nomination.save!
    a_document.publish
    assert(a_document.is_published?)
  end

  def test_nomination_after_publish
    a_nomination = Nomination.sample_nomination
    a_nomination.set_status_approved
    a_nomination.save!
    a_document = a_nomination.document
    a_document.publish
    a_document.save!
    a_team_member = TeamMember.sample_secret
    a_team_member.save!
    assert_raises(BusinessRuleError) { a_document.nominate(a_team_member) }
  end

  def test_security_violation_on_nomination
    a_document = Document.sample_secret
    a_document.save!
    a_team_member = TeamMember.sample_admin
    a_team_member.save!
    assert_raises(BusinessRuleError) { a_document.nominate(a_team_member) }
  end

  def test_good_eradication
    a_document = Document.sample_normal
    a_document.save!
    a_document.eradicate
  end

  def test_eradication_with_nominations
    a_nomination = Nomination.sample_nomination
    a_nomination.save!
    a_document = a_nomination.document
    assert_raises(BusinessRuleError) { a_document.eradicate }
  end

  def test_equals
    a_document = Document.sample_normal
    z_document = Document.sample_secret
    assert(a_document == a_document)
    refute(a_document.eql?(z_document))
  end

  def test_to_s
    a_document = Document.sample_normal
    assert_match(/Document/, a_document.to_s)
  end

  def test_as_json
    a_document = Document.sample_normal
    a_document.save!
    refute_empty(a_document.as_json)
  end

end