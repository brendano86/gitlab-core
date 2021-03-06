class Admin::LogsController < Admin::ApplicationController
  prepend EE::Admin::LogsController

  before_action :loggers

  def show
  end

  private

  def loggers
    @loggers ||= [
      Gitlab::AppLogger,
      Gitlab::GitLogger,
      Gitlab::EnvironmentLogger,
      Gitlab::SidekiqLogger,
      Gitlab::RepositoryCheckLogger
    ]
  end
end
