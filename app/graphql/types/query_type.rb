module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # Person

    field :persons, [Types::PersonType], null: false

    def persons
      Person.all
    end

    field :person, Types::PersonType, null: false do
      argument :id, ID, required: true
    end

    def person(id:)
      Person.find(id)
    end

    # Team

    field :teams, [Types::TeamType], null: false

    def teams
      Team.all
    end

    field :team, Types::TeamType, null: false do
      argument :id, ID, required: true
    end

    def team(id:)
      Team.find(id)
    end

    # Team Member

    field :team_members, [Types::TeamMemberType], null: false

    def team_members
      TeamMember.all
    end

    field :team_member, Types::TeamMemberType, null: false do
      argument :id, ID, required: true
    end

    def team_member(id:)
      TeamMember.find(id)
    end

    # Document

    field :documents, [Types::DocumentType], null: false

    def documents
      Document.all
    end

    field :document, Types::DocumentType, null: false do
      argument :id, ID, required: true
    end

    def document(id:)
      Document.find(id)
    end

    # Project

    field :projects, [Types::ProjectType], null: false

    def projects
      Project.all
    end

    field :project, Types::ProjectType, null: false do
      argument :id, ID, required: true
    end

    def project(id:)
      Project.find(id)
    end

    # Nomination

    field :nominations, [Types::NominationType], null: false

    def nominations
      Nomination.all
    end

    field :nomination, Types::NominationType, null: false do
      argument :id, ID, required: true
    end

    def nomination(id:)
      Nomination.find(id)
    end

  end
end
