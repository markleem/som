module Types
  class NominationType < Types::BaseObject
    field :id, ID, null: false
    field :comments, String, null: false
    field :nomination_date, GraphQL::Types::ISO8601Date, null: true
    field :status, String, null: false
    field :team_member, Types::TeamMemberType, null: false
    field :document, Types::DocumentType, null: false

    def status
      object.status_type
    end
  end
end
