module Mutations
  class CreatePerson < BaseMutation
    argument :name, String, required: true
    argument :title, String, required: false
    argument :email, String, required: false

    field :person, Types::PersonType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      initialize_the_errors
      a_name = args[:name]
      a_title = args[:title]
      an_email = args[:email]
      begin
        self.the_object = Person.new(a_name)
      rescue BusinessRuleError => e
        the_errors << e.message
      end

      if no_errors?
        set()
        unless a_title.nil?
          begin
            a_person.title = a_title
          rescue BusinessRuleError => e
            the_errors << e.message
          end
        end
        unless an_email.nil?
          begin
            a_person.email = an_email
          rescue BusinessRuleError => e
            the_errors << e.message
          end
        end
      end

      begin
        a_person.save! if the_errors.empty?
      rescue BusinessRuleError => e
        the_errors << e.message
      end

      {
          person: a_person,
          errors: the_errors
      }
    end
  end
end