# frozen_string_literal: true

module DAO
  # class TeamMember
  class TeamMember < Model
    self.table_name = "team_members"

    def self.model_class
      ::TeamMember
    end

    belongs_to :person, inverse_of: :team_members
    belongs_to :team, inverse_of: :team_members
    has_many :nominations, inverse_of: :team_member

    def model_nominations
      nominations.to_a.collect(&:model)
    end
  end
end
