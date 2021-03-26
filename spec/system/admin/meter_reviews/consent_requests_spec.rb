require 'rails_helper'

RSpec.describe 'consent_requests', type: :system do

  let!(:school)                { create(:school) }
  let!(:dcc_meter)             { create(:electricity_meter, school: school, dcc_meter: true, consent_granted: false) }

  let!(:admin)                 { create(:admin) }

  before(:each) do
    login_as admin
  end

  context 'with pending meter review' do

    it 'should provide navigation' do
      visit root_path
      click_on 'Admin'
      click_on 'Meter Reviews'
      expect(page).to have_link("Request consent", href: new_admin_school_consent_request_path(school) )
    end
  end

  context 'requesting consent' do

    context 'with no users' do

      before(:each) do
        visit new_admin_school_consent_request_path(school)
      end

      it 'should say there are no users' do
        expect(page).to have_text("The school has no staff or admin users")
      end

      it 'should link to add a user' do
        expect(page).to have_link("Add user", href: school_users_path(school))
      end
    end

    context 'with users' do
      let!(:school_admin)          { create(:school_admin, school: school)}
      let!(:staff)                 { create(:staff, school: school)}

      before(:each) do
        visit new_admin_school_consent_request_path(school)
      end

      it 'should display user name and role' do
        expect(page).to have_text(staff.name)
        expect(page).to have_text(staff.staff_role.title)
        expect(page).to have_text(school_admin.name)
        expect(page).to have_text(school_admin.staff_role.title)
      end

      it 'should link to manage users' do
        expect(page).to have_link("Manage users", href: school_users_path(school))
      end

      context 'when invalid form is submitted' do
        it 'should display an error' do
          click_on 'Request consent'
          expect(page.has_text?("You must select at least one user")).to be true
          expect(ActionMailer::Base.deliveries.count).to be 0
        end
      end

      context 'when valid form is submitted' do
        before(:each) do
          find(:css, "#consent_request_user_ids_#{school_admin.id}").set(true)
          click_on 'Request consent'
        end

        it 'should confirm email has been sent' do
          expect(page.has_text?("Consent has been requested")).to be true
        end

        it 'should send the email' do
          expect(ActionMailer::Base.deliveries.count).to be 1
        end
      end

    end
  end

  context 'when providing consent' do
    let!(:consent_statement) { ConsentStatement.create!(title: 'Some consent statement', content: 'Some consent text', current: true) }

    let!(:school_admin)          { create(:school_admin, school: school)}

    before(:each) do
      login_as(school_admin)
      visit school_consents_path(school)
    end

    it 'should display statement and terms checkbox' do
      expect(page).to have_content(consent_statement.content.to_plain_text)
      expect(page).to have_content('I confirm agreement with the Energy Sparks')
    end

    it 'should record consent' do
      fill_in 'Name', with: 'Boss user'
      fill_in 'Job title', with: 'Boss'
      fill_in 'School name', with: 'Boss school'

      click_on 'I give permission'

      school.reload
      consent_grant = school.consent_grants.last
      expect(consent_grant.name).to eq('Boss user')
      expect(consent_grant.job_title).to eq('Boss')
      expect(consent_grant.school_name).to eq('Boss school')
      expect(consent_grant.user).to eq(school_admin)
      expect(consent_grant.school).to eq(school)

    end

  end
end
