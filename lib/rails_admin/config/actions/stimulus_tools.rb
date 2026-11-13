# Collection action on Workout for the intended stimulus (#1992). Every step works on workouts
# the app already has -- nothing here imports or parses a workout, and nothing calls an LLM:
# recalculate (StimulusRecalculation), fetch CrossFit's posted text for existing Crossfit.com
# workouts (StimulusTextFetch), and the accuracy report. GET renders the form; POST runs a dry
# run in place or queues the step.
module RailsAdmin
  module Config
    module Actions
      class StimulusTools < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option(:only) { 'Workout' }
        register_instance_option(:collection) { true }
        register_instance_option(:http_methods) { %i[get post] }
        register_instance_option(:authorization_key) { :update }
        register_instance_option(:link_icon) { 'fas fa-bullseye' }

        register_instance_option :controller do
          proc do
            @tools = StimulusToolsForm.new(params)
            if request.get? || @tools.renders_in_place?
              @summary = @tools.dry_run_summary if request.post?
              render @action.template_name
            else
              flash[:success] = @tools.run
              redirect_to index_path
            end
          end
        end
      end
    end
  end
end
