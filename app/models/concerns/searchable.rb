# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    extend ClassMethods
  end

  module ClassMethods
    def fuzzy_search_predicate_key(*fields, association: nil, model_name: nil, polymorphic: false, matcher: 'cont')
      fields_clause =
        if polymorphic.present?
          raise ArgumentError, "Searching polymorphic associations on #{name} requires a model_name" \
            unless model_name.present?
          raise ArgumentError, "Searching polymorphic associations on #{name} requires the association" \
            unless association.present?

          fields.sort.map do |field|
            if model_name
              "#{model_name.to_s.downcase}_of_#{association}_type_#{field}"
            else
              field
            end
          end
        elsif association.present?
          fields.sort.map do |field|
            [association.to_s.downcase.pluralize, field].join('_')
          end
        else
          fields.sort
        end
      return fields_clause.join('_or_') unless matcher.present?

      "#{fields_clause.join('_or_')}_#{matcher}"
    end
  end
end
