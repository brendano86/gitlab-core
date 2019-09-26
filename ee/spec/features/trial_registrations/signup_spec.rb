# frozen_string_literal: true

require 'spec_helper'

describe 'Trial Sign Up', :js do
  let(:user_attrs) { attributes_for(:user, first_name: 'GitLab', last_name: 'GitLab') }

  describe 'on GitLab.com' do
    before do
      stub_feature_flags(invisible_captcha: false)
      stub_feature_flags(improved_trial_signup: true)
      allow(Gitlab).to receive(:com?).and_return(true).at_least(:once)
    end

    context 'with the unavailable username' do
      let(:existing_user) { create(:user) }

      it 'shows the error about existing username' do
        visit(new_trial_registration_path)
        click_on 'Register'

        within('div#register-pane') do
          fill_in 'new_user_username', with: existing_user.username
        end

        expect(page).to have_content('Username is already taken.')
      end
    end

    context 'entering' do
      using RSpec::Parameterized::TableSyntax

      where(:case_name, :first_name, :last_name, :suggested_username) do
        'first name'               | 'foobar'  | nil      | 'foobar'
        'last name'                | nil       | 'foobar' | 'foobar'
        'first name and last name' | 'foo'     | 'bar'    | 'foo_bar'
      end

      with_them do
        it 'suggests the username' do
          visit(new_trial_registration_path)
          click_on 'Register'

          within('div#register-pane') do
            fill_in 'new_user_first_name', with: first_name if first_name
            fill_in 'new_user_last_name', with: last_name if last_name
          end
          find('body').click

          expect(page).to have_field('new_user_username', with: suggested_username)
        end
      end
    end
  end
end