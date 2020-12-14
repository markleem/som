module Types
  class TeamMemberType < Types::BaseObject
    field :id, ID, null: false
    field :security_level, String, null: false
    field :team, Types::TeamType, null: false
    field :person, Types::PersonType, null: false
    field :nominations, [Types::NominationType], null: false

    def security_level
      object.security_level.level
    end
  end
end
