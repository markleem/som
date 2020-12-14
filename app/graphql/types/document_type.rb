module Types
  class DocumentType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :publication_date, GraphQL::Types::ISO8601Date, null: true
    field :security_level, String, null: false
    field :nominations, [Types::NominationType], null: false

    def security_level
      object.security_level.level
    end
  end
end
