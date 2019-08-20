require 'rails_helper'

RSpec.describe 'alert type management', type: :system do

  let!(:admin)  { create(:user, role: 'admin')}

  let(:gas_fuel_alert_type_title) { 'Your gas usage is too high' }
  let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :termly, title: gas_fuel_alert_type_title, has_ratings: has_ratings) }
  let(:has_ratings){ true }

  describe 'managing associated activities' do

    let!(:alert_type_rating) { create(:alert_type_rating, alert_type: gas_fuel_alert_type)}
    let!(:activity_category) { create(:activity_category)}
    let!(:activity_type_1) { create(:activity_type, name: 'Turn off the lights', activity_category: activity_category)}
    let!(:activity_type_2) { create(:activity_type, name: 'Turn down the heating', activity_category: activity_category)}

    before do
      sign_in(admin)
      visit root_path
      click_on 'Alert Types'
    end

    it 'assigns activity types to alerts via a text box position' do

      click_on gas_fuel_alert_type_title
      click_on 'Content management'

      click_on 'Activity types'

      expect(page.find_field('Turn off the light').value).to be_blank
      expect(page.find_field('Turn down the heating').value).to be_blank

      fill_in 'Turn down the heating', with: '1'

      click_on 'Update associated activity type', match: :first
      click_on 'Activity types'

      expect(page.find_field('Turn off the light').value).to be_blank
      expect(page.find_field('Turn down the heating').value).to eq('1')

      expect(alert_type_rating.activity_types).to match_array([activity_type_2])
      expect(alert_type_rating.alert_type_rating_activity_types.first.position).to eq(1)

    end
  end

  describe 'creating alert content' do

    let!(:alert) do
      create(:alert, alert_type: gas_fuel_alert_type, template_data: {gas_percentage: '10%'}, school: create(:school))
    end

    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Alert Types'
    end

    context 'with ratings' do

      it 'allows creation and editing of alert content', js: true do
        click_on gas_fuel_alert_type_title
        click_on 'Content management'

        click_on 'New content rating range'

        fill_in 'Rating from', with: '0'
        fill_in 'Rating to', with: '10'
        fill_in 'Description', with: 'For schools with bad heating management'

        select 'red', from: 'Colour'

        check 'Teacher dashboard alert'
        fill_in 'Teacher dashboard title', with: 'Your gas usage is too high'


        within '.teacher_dashboard_alert_active' do

          click_on 'Timings'
          find_field('Start date').click
          fill_in 'Start date', with: '01/12/2019'

          click_on 'Preview'
          within '#teacher_dashboard_alert-preview .content' do
            expect(page).to have_content(gas_fuel_alert_type_title)
          end

        end

        check 'Pupil dashboard alert'
        fill_in 'Pupil dashboard title', with: gas_fuel_alert_type_title

        within '.pupil_dashboard_alert_active' do
          click_on 'Preview'
          within '#pupil_dashboard_alert-preview .content' do
            expect(page).to have_content(gas_fuel_alert_type_title)
          end
        end

        check 'Public dashboard alert'
        fill_in 'Public dashboard title', with: 'This school is using gas'

        within '.public_dashboard_alert_active' do
          click_on 'Preview'
          within '#public_dashboard_alert-preview .content' do
            expect(page).to have_content('This school is using gas')
          end
        end

        check 'Management dashboard alert'
        fill_in 'Management dashboard title', with: 'Your school is using gas'

        within '.management_dashboard_alert_active' do
          click_on 'Preview'
          within '#management_dashboard_alert-preview .content' do
            expect(page).to have_content('Your school is using gas')
          end
        end

        check 'Find out more'

        within '.find_out_more_active' do

          fill_in 'Page title', with: 'You are using too much gas!'

          within '.alert_type_rating_content_find_out_more_chart_variable' do
            expect(page).to have_unchecked_field('chart description A')
            expect(page).to have_unchecked_field('chart description B')
            expect(page).to have_checked_field('None')
          end

          choose 'chart description B'
          fill_in 'Chart title', with: 'This is a chart'

          fill_in_trix with: 'You are using {{gas_percentage}} too much gas! You need to do something about it.'

          click_on 'Preview'

          within '#find_out_more-preview .content' do
            expect(page).to have_content('You are using 10% too much gas!')
          end
        end

        check 'SMS content'
        fill_in 'SMS content', with: gas_fuel_alert_type_title

        within '.sms_active' do
          click_on 'Preview'

          within '#sms-preview .content' do
            expect(page).to have_content(gas_fuel_alert_type_title)
          end
        end

        check 'Email content'
        fill_in 'Email title', with: 'Gas usage'

        within '.email_active' do
          fill_in_trix with: 'You are using {{gas_percentage}} too much gas! You need to do something about it.'

          click_on 'Preview'

          within '#email-preview .content' do
            expect(page).to have_content('You are using 10% too much gas!')
          end
        end

        click_on 'Create content'

        expect(gas_fuel_alert_type.ratings.size).to eq(1)
        alert_type_rating = gas_fuel_alert_type.ratings.first
        expect(alert_type_rating.content_versions.size).to eq(1)
        first_content = alert_type_rating.current_content
        expect(first_content.find_out_more_title).to eq('You are using too much gas!')
        expect(first_content.sms_content).to eq(gas_fuel_alert_type_title)
        expect(first_content.teacher_dashboard_alert_start_date).to eq(Date.new(2019, 12, 1))
        expect(first_content.public_dashboard_title).to eq('This school is using gas')
        expect(first_content.management_dashboard_title).to eq('Your school is using gas')

        click_on 'Edit'

        fill_in 'Page title', with: 'Stop using so much gas!'
        click_on 'Update content'

        expect(alert_type_rating.content_versions.size).to eq(2)
        second_content = alert_type_rating.current_content
        expect(second_content.find_out_more_title).to eq('Stop using so much gas!')
        expect(second_content.find_out_more_chart_variable).to eq('chart_b')
        expect(second_content.find_out_more_chart_title).to eq('This is a chart')
      end
    end

    context 'without ratings' do

      let(:has_ratings){ false }

      it 'does not ask for ratings and defaults them' do
        click_on gas_fuel_alert_type_title
        click_on 'Content management'

        click_on 'New content'

        fill_in 'Description', with: 'For schools with bad heating management'

        select 'red', from: 'Colour'


        click_on 'Create content'

        expect(gas_fuel_alert_type.ratings.size).to eq(1)
        alert_type_rating = gas_fuel_alert_type.ratings.first
        expect(alert_type_rating.rating_from).to eq(0.0)
        expect(alert_type_rating.rating_to).to eq(10.0)
      end

    end
  end

  describe 'general editing' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Alert Types'
    end

    it 'allows fields to be edited and validates title' do
      click_on gas_fuel_alert_type_title
      click_on 'Edit'

      fill_in 'Title', with: ''
      click_on 'Update Alert type'

      expect(page).to have_content("Title can't be blank")

      new_title = 'New title'
      new_description = 'New description'
      new_analysis = 'New analysis'

      fill_in 'Title', with: new_title
      fill_in 'Description', with: new_description
      fill_in 'Analysis', with: new_analysis
      choose 'Weekly'
      click_on 'Update Alert type'

      expect(page).to have_content('Alert type updated')
      expect(page).to have_content(new_title)
      expect(page).to have_content(new_description)
      expect(page).to have_content(new_analysis)
      expect(page).to have_content('Weekly')
    end
  end
end
