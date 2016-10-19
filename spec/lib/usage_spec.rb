
require 'rails_helper'
require 'usage.rb'

describe 'Usage' do
  let!(:school) { FactoryGirl.create :school }
  let!(:supply) { :electricity }
  let!(:electricity_meter_1) { FactoryGirl.create :meter, school_id: school.id, meter_type: supply }
  let!(:electricity_meter_2) { FactoryGirl.create :meter, school_id: school.id, meter_type: supply }
  let!(:gas_meter_1) { FactoryGirl.create :meter, school_id: school.id, meter_type: :gas }
  let!(:last_week) { Date.today - 7.days..Date.today - 1.days }
  let!(:week_before) { Date.today - 14.days..Date.today - 8.days }
  before(:each) do
    [last_week, week_before].each do |week|
      week.each do |date|
        FactoryGirl.create(
          :meter_reading,
          meter_id: electricity_meter_1.id,
          read_at: DateTime.parse("#{date} 01:00").utc,
          value: 100
        )
        FactoryGirl.create(
          :meter_reading,
          meter_id: electricity_meter_1.id,
          read_at: DateTime.parse("#{date} 23:00").utc,
          value: 200
        )
        FactoryGirl.create(
          :meter_reading,
          meter_id: electricity_meter_2.id,
          read_at: DateTime.parse("#{date} 01:00").utc,
          value: 150
        )
        FactoryGirl.create(
          :meter_reading,
          meter_id: electricity_meter_2.id,
          read_at: DateTime.parse("#{date} 23:00").utc,
          value: 200
        )
        FactoryGirl.create(
          :meter_reading,
          meter_id: gas_meter_1.id,
          read_at: DateTime.parse("#{date} 01:00").utc,
          value: 10
        )
        FactoryGirl.create(
          :meter_reading,
          meter_id: gas_meter_1.id,
          read_at: DateTime.parse("#{date} 23:00").utc,
          value: 20
        )
      end
    end
  end
  describe '#daily_usage' do
    context 'school has no meters for the supply' do
      it 'sets the usage value to zero for each day' do
        # test with invalid supply
        supply = 999
        expect(school.daily_usage(supply, last_week).inject(0) { |a, e| a + e[1] }).to eq 0
      end
    end
    context 'if no readings are found for the date' do
      it 'sets the usage value to zero' do
        # start the day before there are meter readings
        dates_no_readings = Date.today - 30.days..Date.today - 30.days
        expect(school.daily_usage(supply, dates_no_readings)[0][1]).to eq 0
      end
    end
    it 'returns a total of all reading values for each date in the date array' do
      expect(school.daily_usage(supply, last_week)).to eq [
        [Date.today - 7.days, 650],
        [Date.today - 6.days, 650],
        [Date.today - 5.days, 650],
        [Date.today - 4.days, 650],
        [Date.today - 3.days, 650],
        [Date.today - 2.days, 650],
        [Date.today - 1.days, 650]
      ]
    end
  end

  describe '#last_reading_date' do
    context 'no previous readings are found' do
      it "returns nil" do
        new_school = FactoryGirl.create :school
        expect(new_school.last_reading_date(:electricity, Date.today)).to be_nil
      end
    end
    context "readings are found" do
      it "returns a date" do
        expect(school.last_reading_date(:electricity, Date.today)).to be_a_kind_of Date
      end
      it "returns the last date on/before the date specified" do
        expect(school.last_reading_date(:electricity, Date.today)).to eq Date.today - 1.days
        expect(school.last_reading_date(:electricity, Date.today - 8.days)).to eq Date.today - 8.days
      end
    end
  end

  describe '#last_friday_with_readings' do
    context 'no previous readings are found' do
      it "returns nil" do
        new_school = FactoryGirl.create :school
        expect(new_school.last_friday_with_readings(:electricity)).to be_nil
      end
    end
    context "readings are found on a Friday" do
      it "returns a date" do
        expect(school.last_friday_with_readings(:electricity)).to be_a_kind_of Date
      end
      it "returns a Friday" do
        expect(school.last_friday_with_readings(:electricity).friday?).to be_truthy
      end
      it "returns the last Friday" do
        expect(school.last_friday_with_readings(:electricity)).to be_between(last_week.first, last_week.last)
      end
    end
  end
end
