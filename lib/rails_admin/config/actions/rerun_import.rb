# Member actions on the WorkoutImport review queue that re-enqueue ScrapeCfWodJob for the row's
# date with one specific parser and no fallback to the other. RailsAdmin menu links are GET, so
# GET renders a confirmation form and POST enqueues.
module RailsAdmin
  module Config
    module Actions
      class RerunImport < RailsAdmin::Config::Actions::Base
        register_instance_option(:only) { 'WorkoutImport' }
        register_instance_option(:member) { true }
        register_instance_option(:http_methods) { %i[get post] }
        register_instance_option(:template_name) { :rerun_import }
        register_instance_option(:authorization_key) { :update }
        register_instance_option(:link_icon) { 'fas fa-redo' }

        register_instance_option :controller do
          proc do
            if request.post?
              parser = @action.parser
              ScrapeCfWodJob.perform_later(@object.workout_date, parser, nil)
              flash[:success] = "Re-running #{@object.workout_date} with the #{parser} parser."
              redirect_to index_path
            else
              render @action.template_name
            end
          end
        end
      end

      class RerunHeuristic < RerunImport
        RailsAdmin::Config::Actions.register(self)

        def parser = :heuristic
      end

      class RerunLlm < RerunImport
        RailsAdmin::Config::Actions.register(self)

        def parser = :llm
      end
    end
  end
end
