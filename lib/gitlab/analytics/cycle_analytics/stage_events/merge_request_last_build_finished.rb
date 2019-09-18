# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module StageEvents
        class MergeRequestLastBuildFinished < SimpleStageEvent
          def self.name
            s_("CycleAnalyticsEvent|Merge request last build finish time")
          end

          def self.identifier
            :merge_request_last_build_finished
          end

          def object_type
            MergeRequest
          end

          def timestamp_projection
            mr_metrics_table[:latest_build_finished_at]
          end

          # rubocop: disable CodeReuse/ActiveRecord
          def apply_query_customization(query)
            query.joins(:metrics)
          end
          # rubocop: enable CodeReuse/ActiveRecord
        end
      end
    end
  end
end
