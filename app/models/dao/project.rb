# frozen_string_literal: true

module DAO
  # class Project
  class Project < Model
    self.table_name = "projects"

    def self.model_class
      ::Project
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
