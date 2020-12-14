module Types
  class MutationType < Types::BaseObject
    field :create_person, mutation: Mutations::CreatePerson
  end
end
