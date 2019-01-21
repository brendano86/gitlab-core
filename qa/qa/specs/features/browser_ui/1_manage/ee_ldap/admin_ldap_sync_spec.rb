# frozen_string_literal: true

module QA
  # https://gitlab.com/gitlab-org/quality/nightly/issues/49
  context 'Manage', :orchestrated, :ldap_no_tls, :ldap_tls, :quarantine do
    describe 'LDAP admin sync' do
      it 'Syncs admin users' do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)

        Page::Main::Login.perform do |login_page|
          user = Struct.new(:ldap_username, :ldap_password).new('adminuser1', 'password')

          login_page.sign_in_using_ldap_credentials(user)
        end

        Page::Main::Menu.perform do |menu|
          expect(menu).to have_personal_area

          # The ldap_sync_worker_cron job is set to run every minute
          admin_synchronised = menu.wait(max: 80, time: 1, reload: true) do
            menu.has_admin_area_link?
          end

          expect(admin_synchronised).to be_truthy
        end
      end
    end
  end
end
