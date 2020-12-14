# frozen_string_literal: true

module DAO
  # class Nomination
  class Nomination < Model
    self.table_name = "nominations"

    def self.model_class
      ::Nomination
    end

    belongs_to :document, inverse_of: :nominations
    belongs_to :team_member, inverse_of: :nominations
  end
end
