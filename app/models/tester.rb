class Tester

  def self.test1
    tm1 = TeamMember.sample_admin

    tm2 = TeamMember.sample_chair

    # tm3 = TeamMember.sample_no_nominate

    # tm4 = TeamMember.sample_secret

    d1 = Document.sample_normal

    d2 = Document.sample_secret

    n1 = d1.nominate(tm2)
    n1.save!

    begin
      d2.nominate(tm4)
    rescue BusinessRuleError => e
      bad01 = e
    end

    begin
      d2.nominate(tm2)
    rescue BusinessRuleError => e
      bad02 = e
    end

    j1 = tm1.as_json
    j2 = d2.as_json
    j3 = n1.as_json

    n1.set_status_approved
    n1.save!

    d2.publish
    d2.save!

    n2 = Nomination.sample_nomination

    puts "done"

  end

end