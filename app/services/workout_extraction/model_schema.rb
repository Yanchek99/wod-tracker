module WorkoutExtraction
  # Builds a JSON-schema "properties" hash from an ActiveRecord model's columns, so the LLM
  # extraction schema stays in sync with the model instead of duplicating field names and types
  # by hand. Columns the LLM shouldn't see or set (ids, FKs, timestamps, positions we assign
  # ourselves) are named in except:; fields the LLM should see that aren't plain columns
  # (virtual setters, ActionText, restricted-subset enums) are named in overrides: and win over
  # anything auto-derived for that name.
  module ModelSchema
    JSON_TYPES = { text: 'string', decimal: 'number', float: 'number' }.freeze

    def self.properties_for(model_class, except: [], overrides: {})
      excluded = except.map(&:to_s) + overrides.keys.map(&:to_s)
      model_class.columns_hash
                 .except(*excluded)
                 .transform_values { |column| property_for(model_class, column) }
                 .transform_keys(&:to_sym)
                 .merge(overrides)
    end

    def self.property_for(model_class, column)
      return { type: 'string', enum: model_class.public_send(column.name.pluralize).keys } if model_class.defined_enums.key?(column.name)

      { type: JSON_TYPES.fetch(column.type, column.type.to_s) }
    end
  end
end
