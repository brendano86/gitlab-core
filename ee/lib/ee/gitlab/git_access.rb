# frozen_string_literal: true

module EE
  module Gitlab
    module GitAccess
      prepend GeoGitAccess
      extend ::Gitlab::Utils::Override
      include ActionView::Helpers::SanitizeHelper
      include PathLocksHelper

      override :check
      def check(cmd, changes)
        check_geo_license!

        super
      end

      override :can_read_project?
      def can_read_project?
        return true if geo?

        super
      end

      protected

      override :user
      def user
        return if geo?

        super
      end

      private

      override :check_download_access!
      def check_download_access!
        return if geo?

        super
      end

      override :check_change_access!
      def check_change_access!
        check_size_before_push!

        check_if_license_blocks_changes!

        super

        check_push_size!
      end

      override :check_active_user!
      def check_active_user!
        return if geo?

        super
      end

      def check_geo_license!
        if ::Gitlab::Geo.secondary? && !::Gitlab::Geo.license_allows?
          raise ::Gitlab::GitAccess::UnauthorizedError, 'Your current license does not have GitLab Geo add-on enabled.'
        end
      end

      def geo?
        actor == :geo
      end

      def check_size_before_push!
        if check_size_limit? && project.above_size_limit?
          raise ::Gitlab::GitAccess::UnauthorizedError, ::Gitlab::RepositorySizeError.new(project).push_error
        end
      end

      def check_if_license_blocks_changes!
        if ::License.block_changes?
          message = ::LicenseHelper.license_message(signed_in: true, is_admin: (user && user.admin?))
          raise ::Gitlab::GitAccess::UnauthorizedError, strip_tags(message)
        end
      end

      def check_push_size!
        return unless check_size_limit?

        # Use #quarantine_size to get correct push size whenever a lof of changes
        # gets pushed at the same time containing the same blobs. This is only
        # doable if GIT_OBJECT_DIRECTORY_RELATIVE env var is set and happens
        # when git push comes from CLI (not via UI and API).
        #
        # Fallback to determining push size using the changes_list so we can still
        # determine the push size if env var isn't set (e.g. changes are made
        # via UI and API).
        push_size = check_quarantine_size? ? quarantine_size : changes_size

        if project.changes_will_exceed_size_limit?(push_size)
          raise ::Gitlab::GitAccess::UnauthorizedError, ::Gitlab::RepositorySizeError.new(project).new_changes_error
        end
      end

      def check_quarantine_size?
        strong_memoize(:check_quarantine_size) do
          git_env = ::Gitlab::Git::HookEnv.all(repository.gl_repository)

          git_env['GIT_OBJECT_DIRECTORY_RELATIVE'].present? && ::Feature.enabled?(:quarantine_push_size_check, default_enabled: true)
        end
      end

      def quarantine_size
        project.repository.object_directory_size
      end

      def changes_size
        # If there are worktrees with a HEAD pointing to a non-existent object,
        # calls to `git rev-list --all` will fail in git 2.15+. This should also
        # clear stale lock files.
        project.repository.clean_stale_repository_files

        size_in_bytes = 0

        changes_list.each do |change|
          size_in_bytes += repository.new_blobs(change[:newrev]).sum(&:size) # rubocop: disable CodeReuse/ActiveRecord
        end

        size_in_bytes
      end

      def check_size_limit?
        strong_memoize(:check_size_limit) do
          project.size_limit_enabled? &&
            changes_list.any? { |change| !::Gitlab::Git.blank_ref?(change[:newrev]) }
        end
      end
    end
  end
end
