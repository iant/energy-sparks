require 'rails_helper'

describe Programmes::Creator do

  let(:school)          { create(:school) }
  let(:programme_type)  { create(:programme_type_with_activity_types) }

  let(:service) { Programmes::Creator.new(school, programme_type) }

  describe "#create" do
    let(:programme) { school.programmes.first }

    context 'and school has no activities' do
      before(:each) do
        service.create
      end

      it "creates school programme" do
        expect(school.programmes.count).to eql 1
        expect(programme.programme_type).to eql programme_type
      end

      it "starts programme today" do
        expect(programme.started_on).to eql Date.today
      end

      it "marks programme as started" do
        expect(programme.started?).to be true
      end

      it "doesnt create any programme activities by default" do
        expect(programme.programme_activities.any?).to be false
      end

      it "does not have an activity" do
        expect(school.programmes.first.activities.any?).to be false
      end

      it "doesnt enrol twice" do
        service.create
        expect(school.programmes.count).to eql 1
      end

    end

    context "and school has activities" do
      let!(:activity) { create(:activity, school: school, activity_type: programme_type.activity_types.first)}
      before(:each) do
        service.create
      end
      it "copies activities with programme" do
        expect(programme.programme_activities.count).to be 1
        expect(programme.activities.any?).to be true
        expect(programme.activities.first).to eq activity
      end
    end
  end
end
