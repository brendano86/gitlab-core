module EE
  module Gitlab
    module LDAP
      module Sync
        class Groups
          attr_reader :provider, :proxy

          def self.execute
            # Shuffle providers to prevent a scenario where sync fails after a time
            # and only the first provider or two get synced. This shuffles the order
            # so subsequent syncs should eventually get to all providers. Obviously
            # we should avoid failure, but this is an additional safeguard.
            ::Gitlab::LDAP::Config.providers.shuffle.each do |provider|
              Sync::Proxy.open(provider) do |proxy|
                group_sync = self.new(proxy)
                group_sync.update_permissions
              end
            end

            true
          end

          def initialize(proxy)
            @provider = proxy.provider
            @proxy = proxy
          end

          def update_permissions
            unless config.group_base.present?
              logger.debug { "No `group_base` configured for '#{provider}' provider. Skipping" }
              return nil
            end

            logger.debug { "Performing LDAP group sync for '#{provider}' provider" }
            sync_groups
            logger.debug { "Finished LDAP group sync for '#{provider}' provider" }

            if config.admin_group.present?
              logger.debug { "Syncing admin users for '#{provider}' provider" }
              sync_admin_users
              logger.debug { "Finished syncing admin users for '#{provider}' provider" }
            else
              logger.debug { "No `admin_group` configured for '#{provider}' provider. Skipping" }
            end

            if config.external_groups.empty?
              logger.debug { "No `external_groups` configured for '#{provider}' provider. Skipping" }
            else
              logger.debug { "Syncing external users for '#{provider}' provider" }
              sync_external_users
              logger.debug { "Finished syncing external users for '#{provider}' provider" }
            end

            nil
          end

          private

          def sync_groups
            groups_where_group_links_with_provider_ordered.each do |group|
              Sync::Group.execute(group, proxy)
            end
          end

          def sync_admin_users
            Sync::AdminUsers.execute(proxy)
          end

          def sync_external_users
            Sync::ExternalUsers.execute(proxy)
          end

          def groups_where_group_links_with_provider_ordered
            ::Group.where_group_links_with_provider(provider)
              .preload(:ldap_group_links)
              .reorder('ldap_sync_last_successful_update_at ASC, namespaces.id ASC')
              .distinct
          end

          def config
            proxy.adapter.config
          end

          def logger
            Rails.logger
          end
        end
      end
    end
  end
end
