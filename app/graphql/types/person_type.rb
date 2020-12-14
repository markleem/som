module Types
  class PersonType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :title, String, null: true
    field :email, String, null: true
    field :team_members, [Types::TeamMemberType], null: false
  end
end
