require 'test_helper'

module WorkoutExtraction
  class ModelSchemaTest < ActiveSupport::TestCase
    test 'maps plain column types to JSON schema types' do
      properties = ModelSchema.properties_for(Segment, except: %w[id workout_id created_at updated_at position])

      assert_equal({ type: 'string' }, properties[:name])
      assert_equal({ type: 'integer' }, properties[:rounds])
      assert_equal({ type: 'string' }, properties[:notes]) # Segment#notes is a `text` column
    end

    test 'excludes columns named in except:' do
      properties = ModelSchema.properties_for(Segment, except: %w[id workout_id created_at updated_at position])

      assert_not properties.key?(:id)
      assert_not properties.key?(:workout_id)
      assert_not properties.key?(:position)
    end

    test 'auto-detects enum columns and constrains them to the enum values' do
      properties = ModelSchema.properties_for(
        Exercise,
        except: %w[id workout_id movement_id segment_id created_at updated_at position]
      )

      assert_equal({ type: 'string', enum: %w[meter foot inch] }, properties[:distance_unit])
    end

    test 'maps a boolean column to a boolean type' do
      properties = ModelSchema.properties_for(
        Exercise,
        except: %w[id workout_id movement_id segment_id created_at updated_at position]
      )

      assert_equal({ type: 'boolean' }, properties[:ladder_exempt])
    end

    test 'overrides win over any auto-derived value for the same key' do
      properties = ModelSchema.properties_for(
        Exercise,
        except: %w[id workout_id movement_id segment_id created_at updated_at position],
        overrides: { movement_name: { type: 'string' }, distance_unit: { type: 'string', enum: %w[custom] } }
      )

      assert_equal({ type: 'string' }, properties[:movement_name])
      assert_equal({ type: 'string', enum: %w[custom] }, properties[:distance_unit])
    end
  end
end
