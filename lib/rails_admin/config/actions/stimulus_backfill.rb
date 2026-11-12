# Collection action on Workout that runs the intended-stimulus backfill (#1992): scrape past
# CrossFit.com days, extract their Stimulus and Strategy prose, and refit the learner. GET
# renders the form; POST either shows dry-run counts or enqueues StimulusBackfillJob.
module RailsAdmin
  module Config
    module Actions
      class StimulusBackfill < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option(:only) { 'Workout' }
        register_instance_option(:collection) { true }
        register_instance_option(:http_methods) { %i[get post] }
        register_instance_option(:authorization_key) { :update }
        register_instance_option(:link_icon) { 'fas fa-bullseye' }

        register_instance_option :controller do
          proc do
            @backfill = StimulusBackfillForm.new(params)
            if request.get?
              render @action.template_name
            elsif @backfill.dry_run?
              @counts = @backfill.dry_run_counts
              render @action.template_name
            else
              StimulusBackfillJob.perform_later(@backfill.step, **@backfill.job_options)
              flash[:success] = "Queued the stimulus backfill (#{@backfill.step.humanize})."
              redirect_to index_path
            end
          end
        end
      end
    end
  end
end
