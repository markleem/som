module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    attr_accessor :the_object
    attr_accessor :the_errors

    def initialize_the_errors
      self.the_errors = []
    end

    def no_errors?
      the_errors.empty?
    end

    def set(an_object, a_property, a_value)
      return if a_value.nil?
      begin
        an_object.send(a_property, a_value)
      rescue BusinessRuleError => e
        self.the_errors << e.message
      end
    end

  end
end
