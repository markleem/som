module Types
  class NominatableType < Types::BaseUnion
    possible_types Types::DocumentType, Types::ProjectType

    def self.resolve_type(object, context)
      if object.is_a?(Document)
        Types::DocumentType
      elsif object.is_a?(Project)
        Types::ProjectType
      end
    end
  end
end
