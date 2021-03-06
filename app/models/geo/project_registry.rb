class Geo::ProjectRegistry < Geo::BaseRegistry
  belongs_to :project

  validates :project, presence: true, uniqueness: true

  scope :dirty, -> { where(arel_table[:resync_repository].eq(true).or(arel_table[:resync_wiki].eq(true))) }

  def self.failed
    repository_sync_failed = arel_table[:last_repository_synced_at].not_eq(nil)
      .and(arel_table[:last_repository_successful_sync_at].eq(nil))

    wiki_sync_failed = arel_table[:last_wiki_synced_at].not_eq(nil)
      .and(arel_table[:last_wiki_successful_sync_at].eq(nil))

    where(repository_sync_failed.or(wiki_sync_failed))
  end

  def self.synced
    where.not(last_repository_synced_at: nil, last_repository_successful_sync_at: nil)
      .where(resync_repository: false, resync_wiki: false)
  end

  def resync_repository?
    resync_repository || last_repository_successful_sync_at.nil?
  end

  def resync_wiki?
    resync_wiki || last_wiki_successful_sync_at.nil?
  end

  def repository_synced_since?(timestamp)
    last_repository_synced_at && last_repository_synced_at > timestamp
  end

  def wiki_synced_since?(timestamp)
    last_wiki_synced_at && last_wiki_synced_at > timestamp
  end
end
