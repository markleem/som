# frozen_string_literal: true

module DAO
  # class Document
  class Document < Model
    self.table_name = "documents"

    def self.model_class
      ::Document
    end

    has_many :nominations, as: :nominatable, inverse_of: :nominatable

    def self.title_unique?(a_title)
      exists?(title: a_title) ? false : true
    end

    def model_nominations
      nominations.to_a.collect(&:model)
    end
  end
end
