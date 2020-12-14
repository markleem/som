# frozen_string_literal: true

module DAO
  # class Model
  class Model < ApplicationRecord
    self.abstract_class = true

    def self.model_class
      raise(NotImplementedError, "#{self.class.name}#model_class is an abstract class method")
    end

    attr_writer :model

   def model
      return @model if @model.present?
      self.class.model_class.allocate.establish_dao(self)
   end
  end
end
