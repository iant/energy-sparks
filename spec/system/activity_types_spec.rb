require 'rails_helper'

describe 'activity types', type: :system do

  context 'activity types search page' do

    let!(:activity_type_1) { create(:activity_type, name: 'foo', description: 'activity') }
    let!(:activity_type_2) { create(:activity_type, name: 'bar', description: 'activity') }

    it 'links from activity categories page and shows empty page' do
      ClimateControl.modify FEATURE_FLAG_ACTIVITY_TYPE_SEARCH: 'true' do
        visit activity_categories_path
        click_on 'Search'

        expect(page).to have_content('Find pupil activities')
        expect(page).not_to have_content('No results found')
      end
    end

    it 'link is feature flag controlled' do
      ClimateControl.modify FEATURE_FLAG_ACTIVITY_TYPE_SEARCH: 'false' do
        visit activity_categories_path
        expect(page).not_to have_link('Search')
      end
    end

    it 'links to activity categories page' do
      visit search_activity_types_path
      click_on 'All activities'

      expect(page).to have_content('Explore energy saving activities')
    end

    it 'links to interventions page' do
      visit search_activity_types_path
      click_on 'Adult actions'

      expect(page).to have_content('Explore energy saving actions')
    end

    it 'shows search results' do
      visit search_activity_types_path
      fill_in 'query', with: 'foo'
      click_on 'Search'

      expect(page).to have_content(activity_type_1.name)
    end

    it 'paginates search results' do
      Pagy::DEFAULT[:items] = 1
      visit search_activity_types_path
      fill_in 'query', with: 'activity'
      click_on 'Search'

      expect(page).to have_content(activity_type_1.name)
      expect(page).not_to have_content(activity_type_2.name)

      click_on 'Next'

      expect(page).not_to have_content(activity_type_1.name)
      expect(page).to have_content(activity_type_2.name)

      # reset this to prevent problems with other tests..
      Pagy::DEFAULT[:items] = 20
    end

    it 'shows no results' do
      visit search_activity_types_path
      fill_in 'query', with: 'blah'
      click_on 'Search'

      expect(page).to have_content('No results found')
    end

    context 'when filtering' do
      let!(:key_stage_1) { create(:key_stage) }
      let!(:key_stage_2) { create(:key_stage) }
      let!(:subject_1) { create(:subject) }
      let!(:subject_2) { create(:subject) }
      let!(:activity_type_1) { create(:activity_type, name: 'baz one', key_stages: [key_stage_1], subjects: [subject_1]) }
      let!(:activity_type_2) { create(:activity_type, name: 'baz two', key_stages: [key_stage_2], subjects: [subject_2]) }

      before :each do
        visit search_activity_types_path
      end

      it 'finds all with no filter' do
        fill_in 'query', with: 'baz'
        click_on 'Search'
        expect(page).to have_content('baz one')
        expect(page).to have_content('baz two')
      end

      it 'shows result count' do
        fill_in 'query', with: 'baz'
        click_on 'Search'
        expect(page).to have_content('2 results found')
      end

      it 'finds result with key stage filter' do
        fill_in 'query', with: 'baz'
        click_on 'Search'
        click_on key_stage_1.name
        expect(page).to have_content('baz one')
        expect(page).not_to have_content('baz two')
      end

      it 'keeps filters for next search' do
        fill_in 'query', with: 'baz'
        click_on 'Search'
        click_on key_stage_1.name
        expect(page).to have_content('baz one')
        expect(page).not_to have_content('baz two')
        fill_in 'query', with: 'baz'
        click_on 'Search'
        expect(page).to have_content('baz one')
        expect(page).not_to have_content('baz two')
      end

      it 'shows result count' do
        fill_in 'query', with: 'baz'
        click_on 'Search'
        click_on key_stage_1.name
        expect(page).to have_content('1 result found')
      end

      it 'finds result with subject filter' do
        fill_in 'query', with: 'baz'
        click_on 'Search'
        click_on subject_1.name
        expect(page).to have_content('baz one')
        expect(page).not_to have_content('baz two')
      end

      it 'finds none if key stage and subject filtered' do
        fill_in 'query', with: 'baz'
        click_on 'Search'
        click_on key_stage_1.name
        click_on subject_2.name
        expect(page).to have_content('No results found')
      end
    end
  end
end
