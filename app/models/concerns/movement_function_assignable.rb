module MovementFunctionAssignable
  extend ActiveSupport::Concern

  included do
    has_many :movement_function_assignments, dependent: :destroy

    scope :with_function, lambda { |function|
      joins(:movement_function_assignments)
        .where(movement_function_assignments: { movement_function: function_value(function) })
        .distinct
    }
    scope :with_function_role, lambda { |function, role|
      joins(:movement_function_assignments)
        .where(movement_function_assignments: {
                 movement_function: function_value(function),
                 role: role_value(role)
               })
        .distinct
    }

    self::FUNCTIONS.each_key do |function_name|
      define_method(:"function_#{function_name}?") { function?(function_name) }
    end

    after_save :sync_function_roles, if: :function_roles_assigned?
  end

  def function_roles=(role_map)
    @function_role_assignments = self.class.normalize_function_roles(role_map)
  end

  def function?(function)
    movement_function_assignments.any? do |assignment|
      assignment.movement_function == self.class.function_name(function)
    end
  end

  def function_role(function)
    movement_function_assignments.find do |assignment|
      assignment.movement_function == self.class.function_name(function)
    end&.role
  end

  class_methods do
    def normalize_function_roles(role_map)
      role_map.flat_map do |role, functions|
        Array(functions).filter_map do |function|
          next if function.blank?

          {
            movement_function: function_value(function),
            role: role_value(role)
          }
        end
      end
    end
  end

  private

  def function_roles_assigned?
    defined?(@function_role_assignments)
  end

  def sync_function_roles
    movement_function_assignments.delete_all
    movement_function_assignments.create!(@function_role_assignments) if @function_role_assignments.any?
  end
end
