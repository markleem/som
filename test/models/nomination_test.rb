require "test_helper"

class NominationTest < MiniTest::Unit::TestCase
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
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_nomination = a_document.nominate(a_team_member)
    a_nomination.comments = "Good document"
    a_nomination.save!
    a_nomination.reload
    assert(a_nomination.persisted?)
    assert(a_nomination.is_status_pending?)
    assert_equal(a_nomination.class_name, "Nomination")
    refute_empty(Nomination.all)
  end

  def test_duplicate_construction_with_same_document_and_team_member
    a_document = Document.sample_normal
    a_document.save!
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    a_nomination = a_document.nominate(a_team_member)
    a_nomination.save!
    assert_raises(BusinessRuleError) { a_document.nominate(a_team_member) }
  end

  def test_bad_construction_with_nil_team_member
    a_document = Document.sample_normal
    a_document.save!
    assert_raises(BusinessRuleError) { Nomination.new(nil, a_document) }
  end

  def test_bad_construction_with_wrong_type_team_member
    a_document = Document.sample_normal
    a_document.save!
    assert_raises(BusinessRuleError) { Nomination.new(a_document, a_document) }
  end

  def test_bad_construction_with_nil_document
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    assert_raises(BusinessRuleError) { Nomination.new(a_team_member, nil) }
  end

  def test_bad_construction_with_wrong_type_document
    a_team_member = TeamMember.sample_chair
    a_team_member.save!
    assert_raises(BusinessRuleError) { Nomination.new(a_team_member, a_team_member) }
  end

  def test_adding_team_member_to_existing_nomination
    a_nomination = Nomination.sample_document_nomination
    a_nomination.save!
    a_team_member = TeamMember.sample_secret
    a_team_member.save!
    assert_raises(BusinessRuleError) { a_nomination.add_team_member(a_team_member) }
  end

  def test_adding_document_to_existing_nomination
    a_nomination = Nomination.sample_document_nomination
    a_nomination.save!
    a_document = Document.sample_secret
    a_document.save!
    assert_raises(BusinessRuleError) { a_nomination.add_nominatable(a_document) }
  end

  def test_good_eradication
    a_nomination = Nomination.sample_document_nomination
    a_nomination.save!
    a_nomination.eradicate
    assert_raises(BusinessRuleError) { a_nomination.save! }
  end

  def test_eradication_of_approved_nomination
    a_nomination = Nomination.sample_document_nomination
    a_nomination.set_status_approved
    a_nomination.save!
    assert_raises(BusinessRuleError) { a_nomination.eradicate }
  end

  def test_eradication_of_rejected_nomination
    a_nomination = Nomination.sample_document_nomination
    a_nomination.set_status_rejected
    a_nomination.save!
    assert_raises(BusinessRuleError) { a_nomination.eradicate }
  end

  def test_statuses
    a_nomination = Nomination.sample_document_nomination
    a_nomination.save!
    assert(a_nomination.is_status_pending?)
    a_nomination.set_status_in_review
    assert(a_nomination.is_status_in_review?)
    a_nomination.set_status_approved
    assert(a_nomination.is_status_approved?)
    a_nomination.set_status_rejected
    assert(a_nomination.is_status_rejected?)
  end

  def test_equals
    a_nomination = Nomination.sample_document_nomination
    a_nomination.save!
    a_team_member = a_nomination.team_member
    a_team_member.security_level.set_level_secret
    a_document = Document.sample_secret
    a_document.save!
    z_nomination = a_document.nominate(a_team_member)
    z_nomination.save!
    assert(a_nomination == a_nomination)
    refute(a_nomination.eql?(z_nomination))
  end

  def test_to_s
    a_nomination = Nomination.sample_document_nomination
    assert_match(/Nomination/, a_nomination.to_s)
  end

  def test_as_json
    a_nomination = Nomination.sample_document_nomination
    a_nomination.save!
    refute_empty(a_nomination.as_json)
  end

end