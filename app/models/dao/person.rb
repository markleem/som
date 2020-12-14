# frozen_string_literal: true

module DAO
  # class Person
  class Person < Model
    self.table_name = "people"

    def self.model_class
      ::Person
    end

    has_many :team_members, inverse_of: :person

    def self.email_unique?(an_email)
      exists?(email: an_email) ? false : true
    end

    def model_team_members
      team_members.to_a.collect(&:model)
    end
  end
end
