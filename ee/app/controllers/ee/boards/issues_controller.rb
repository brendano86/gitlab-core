module EE
  module Boards
    module IssuesController
      def issues_finder
        return super unless board.group_board?

        IssuesFinder.new(current_user, group_id: board_parent.id)
      end

      def project
        @project ||= begin
          if board.group_board?
            ::Project.find(issue_params[:project_id])
          else
            super
          end
        end
      end
    end
  end
end
