module Measurable
  class LeadingPrescription
    def initialize(metrics)
      @metrics = metrics
    end

    def metric
      @metric ||= candidate_metrics.find { |candidate| candidate_can_lead?(candidate) }
    end

    def text
      return unless metric
      return 'max reps' if max_rep?(metric)
      return 'max calories' if max_calorie?(metric)
      return prescribed_work_metric_text(metric) if prescribed_work_metric?(metric)

      metric.value == 1 ? '' : metric.value.to_s
    end

    def additional_metrics
      metrics.reject(&:rep?)
             .reject { |candidate| candidate == metric }
             .reject { |candidate| duration_metric?(candidate) }
             .select { |candidate| visible_metric?(candidate) }
    end

    private

    attr_reader :metrics

    def candidate_metrics
      metrics.select { |candidate| leading_candidate?(candidate) }
    end

    def leading_candidate?(candidate)
      candidate.rep? || candidate.calorie? || distance_metric?(candidate)
    end

    def candidate_can_lead?(candidate)
      return rep_can_lead?(candidate) if candidate.rep?
      return true if max_calorie?(candidate)
      return prescribed_work_can_lead?(candidate) if prescribed_work_metric?(candidate)

      false
    end

    def rep_can_lead?(candidate)
      return true unless structural_single_rep?(candidate)

      metrics.none? { |other_metric| prescribed_work_metric?(other_metric) && prescribed_work_can_lead?(other_metric) }
    end

    def prescribed_work_can_lead?(candidate)
      metrics.all? do |other_metric|
        !visible_metric?(other_metric) ||
          other_metric == candidate ||
          structural_single_rep?(other_metric) ||
          load_detail_allowed?(candidate, other_metric)
      end
    end

    def load_detail_allowed?(candidate, other_metric)
      prescribed_work_metric?(candidate) &&
        load_metric?(other_metric) &&
        (candidate.value.present? || metrics.any? { |metric| structural_single_rep?(metric) })
    end

    def prescribed_work_metric?(candidate)
      candidate.calorie? || distance_metric?(candidate)
    end

    def distance_metric?(candidate)
      Metric::DISTANCE_MEASUREMENTS.include?(candidate.measurement)
    end

    def load_metric?(candidate)
      Metric::LOAD_MEASUREMENTS.include?(candidate.measurement)
    end

    def duration_metric?(candidate)
      candidate.seconds? || candidate.time?
    end

    def visible_metric?(candidate)
      candidate.value.present? || candidate.sex_specific?
    end

    def structural_single_rep?(candidate)
      candidate.rep? && candidate.value == 1
    end

    def max_rep?(candidate)
      candidate.rep? && candidate.value.blank? && !candidate.sex_specific?
    end

    def max_calorie?(candidate)
      candidate.calorie? && candidate.value.blank? && !candidate.sex_specific?
    end

    def prescribed_work_metric_text(candidate)
      return "#{candidate.male_value}/#{candidate.female_value}#{prescribed_work_unit_text(candidate)}" if candidate.sex_specific?

      "#{candidate.value}#{prescribed_work_unit_text(candidate)}"
    end

    def prescribed_work_unit_text(candidate)
      candidate.foot? ? 'ft' : " #{candidate.measurement.singularize}"
    end
  end
end
