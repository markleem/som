module Types
  class TeamType < Types::BaseObject
    field :id, ID, null: false
    field :description, String, null: true
    field :format, String, null: false
    field :team_members, [Types::TeamMemberType], null: false

    def format
      object.format_style_type
    end
  end
end
