# frozen_string_literal: true

module DAO
  # class Team
  class Team < Model
    self.table_name = "teams"

    def self.model_class
      ::Team
    end

    has_many :team_members, inverse_of: :team

    def model_team_members
      team_members.to_a.collect(&:model)
    end
  end
end
