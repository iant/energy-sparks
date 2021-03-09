require 'rails_helper'

describe School do

  let(:today) { Time.zone.today }
  let(:calendar) { create :calendar }
  subject { create :school, :with_school_group, calendar: calendar }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'builds a slug on create using :name' do
    expect(subject.slug).to eq(subject.name.parameterize)
  end

  describe 'FriendlyID#slug_candidates' do
    context 'when two schools have the same name' do
      it 'builds a different slug using :postcode and :name' do
        school = (create_list :school_with_same_name, 2).last
        expect(school.slug).to eq([school.postcode, school.name].join('-').parameterize)
      end
    end
    context 'when three schools have the same name and postcode' do
      it 'builds a different slug using :urn and :name' do
        school = (create_list :school_with_same_name, 3).last
        expect(school.slug).to eq([school.urn, school.name].join('-').parameterize)
      end
    end
  end

  describe '#fuel_types' do
    it 'identifies dual fuel if it has both meters' do
      fuel_configuration = Schools::FuelConfiguration.new(has_gas: true, has_electricity: true)
      subject.configuration.update(fuel_configuration: fuel_configuration)
      expect(subject.fuel_types).to eq :electric_and_gas
    end

    it 'identifies electricity if it has electricity only' do
      fuel_configuration = Schools::FuelConfiguration.new(has_gas: false, has_electricity: true)
      subject.configuration.update(fuel_configuration: fuel_configuration)
      expect(subject.fuel_types).to eq :electric_only
    end

    it 'identifies gas if it has gas only' do
      fuel_configuration = Schools::FuelConfiguration.new(has_gas: true, has_electricity: false)
      subject.configuration.update(fuel_configuration: fuel_configuration)
      expect(subject.fuel_types).to eq :gas_only
    end
  end

  describe '#meters_with_readings' do
    it 'works if explicitly giving a supply type of electricity' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      expect(subject.meters_with_readings(:electricity).first).to eq electricity_meter
      expect(subject.meters_with_readings(:gas)).to be_empty
    end

    it 'works if explicitly giving a supply type of gas' do
      gas_meter = create(:gas_meter_with_reading, school: subject)
      expect(subject.meters_with_readings(:gas).first).to eq gas_meter
      expect(subject.meters_with_readings(:electricity)).to be_empty
    end

    it 'works without a supply type for a gas meter' do
      gas_meter = create(:gas_meter_with_reading, school: subject)
      expect(subject.meters_with_readings.first).to eq gas_meter
    end

    it 'works without a supply type for an electricity' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      expect(subject.meters_with_readings.first).to eq electricity_meter
    end

    it 'ignores deactivated meters' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      electricity_meter_inactive = create(:electricity_meter_with_reading, school: subject, active: false)
      expect(subject.meters_with_readings(:electricity)).to match_array([electricity_meter])
    end
  end

  describe '#meters_with_validated_readings' do
    it 'works if explicitly giving a supply type of electricity' do
      electricity_meter = create(:electricity_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings(:electricity).first).to eq electricity_meter
      expect(subject.meters_with_validated_readings(:gas)).to be_empty
    end

    it 'works if explicitly giving a supply type of gas' do
      gas_meter = create(:gas_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings(:gas).first).to eq gas_meter
      expect(subject.meters_with_validated_readings(:electricity)).to be_empty
    end

    it 'works without a supply type for a gas meter' do
      gas_meter = create(:gas_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings.first).to eq gas_meter
    end

    it 'works without a supply type for an electricity' do
      electricity_meter = create(:electricity_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings.first).to eq electricity_meter
    end

    it 'ignores deactivated meters' do
      electricity_meter = create(:electricity_meter_with_validated_reading, school: subject)
      electricity_meter_inactive = create(:electricity_meter_with_validated_reading, school: subject, active: false)
      expect(subject.meters_with_validated_readings(:electricity)).to match_array([electricity_meter])
    end
  end

  describe '#latest_alerts_without_exclusions' do
    let(:school){ create :school }
    let(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity, frequency: :termly) }


    context 'where there is an alert run' do

      let(:alert_generation_run_1){ create(:alert_generation_run, school: school, created_at: 1.day.ago)}
      let(:alert_generation_run_2){ create(:alert_generation_run, school: school, created_at: Date.today)}

      let!(:alert_1){ create(:alert, alert_type: electricity_fuel_alert_type, school: school, alert_generation_run: alert_generation_run_1) }
      let!(:alert_2){ create(:alert, alert_type: electricity_fuel_alert_type, school: school, alert_generation_run: alert_generation_run_2) }

      it 'selects the dashboard alerts from the most recent run' do
        expect(school.latest_alerts_without_exclusions).to match_array([alert_2])
      end
    end

    context 'where there is no run' do
      it 'returns an empty set' do
        expect(school.latest_alerts_without_exclusions).to be_empty
      end
    end
  end

  describe '#latest_dashboard_alerts' do
    let(:school){ create :school }
    let(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity, frequency: :termly) }
    let(:alert_type_rating){ create(:alert_type_rating, alert_type: electricity_fuel_alert_type) }

    let(:content_version_1){ create(:alert_type_rating_content_version, alert_type_rating: alert_type_rating)}
    let(:alert_1){ create(:alert, alert_type: electricity_fuel_alert_type) }
    let(:alert_2){ create(:alert, alert_type: electricity_fuel_alert_type) }
    let(:content_generation_run_1){ create(:content_generation_run, school: school, created_at: 1.day.ago)}
    let(:content_generation_run_2){ create(:content_generation_run, school: school, created_at: Date.today)}

    context 'where there is a content run' do

      let!(:dashboard_alert_1){ create(:dashboard_alert, alert: alert_1, content_version: content_version_1, content_generation_run: content_generation_run_1) }
      let!(:dashboard_alert_2){ create(:dashboard_alert, alert: alert_1, content_version: content_version_1, content_generation_run: content_generation_run_2) }

      it 'selects the dashboard alerts from the most recent run' do
        expect(school.latest_dashboard_alerts).to match_array([dashboard_alert_2])
      end
    end

    context 'where there is no run' do
      it 'returns an empty set' do
        expect(school.latest_dashboard_alerts).to be_empty
      end
    end
  end

  describe 'authenticate_pupil' do

    let(:school){ create :school }
    let!(:pupil){ create :pupil, pupil_password: 'testTest', school: school }

    it 'selects pupils with the correct password' do
      expect(school.authenticate_pupil('testTest')).to eq(pupil)
    end

    it 'returns nothing if the password does not match' do
      expect(school.authenticate_pupil('barp')).to eq(nil)
    end

    it 'is not case sensitive' do
      expect(school.authenticate_pupil('testtest')).to eq(pupil)
    end
  end

  describe 'process_data!' do

    it 'errors when the school has no meters with readings' do
      school = create(:school, process_data: false)
      expect{
        school.process_data!
      }.to raise_error(School::ProcessDataError, /has no meter readings/)
      expect(school.process_data).to eq(false)
    end

    it 'errors when the school has no floor area' do
      school = create(:school, process_data: false, floor_area: nil)
      electricity_meter = create(:electricity_meter_with_reading, school: school)
      expect{
        school.process_data!
      }.to raise_error(School::ProcessDataError, /has no floor area/)
      expect(school.process_data).to eq(false)
    end

    it 'errors when the school has no pupil numbers' do
      school = create(:school, process_data: false, number_of_pupils: nil)
      electricity_meter = create(:electricity_meter_with_reading, school: school)
      expect{
        school.process_data!
      }.to raise_error(School::ProcessDataError, /has no pupil numbers/)
      expect(school.process_data).to eq(false)
    end

    it 'does not error when the school has floor area, pupil numbers and a meter' do
      school = create(:school, process_data: false)
      electricity_meter = create(:electricity_meter_with_reading, school: school)
      expect{
        school.process_data!
      }.to_not raise_error
      expect(school.process_data).to eq(true)
    end
  end

  describe 'geolocation' do
    it 'the school is geolocated on creation' do
      school = create(:school, latitude: nil, longitude: nil)
      expect(school.latitude).to_not be nil
      expect(school.longitude).to_not be nil
    end

    it 'the school is geolocated if the postcode is changed' do
      school = create(:school)
      school.update(latitude: nil, longitude: nil)
      school.reload

      expect(school.latitude).to be nil
      expect(school.longitude).to be nil

      school.update(postcode: 'B')
      school.reload

      expect(school.latitude).to_not be nil
      expect(school.longitude).to_not be nil
    end
  end

  context 'with partners' do
    let(:partner)       { create(:partner) }
    let(:other_partner) { create(:partner) }

    it "can add a partner" do
      expect(SchoolPartner.count).to eql(0)
      subject.partners << partner
      expect(SchoolPartner.count).to eql(1)
    end

    it "orders partners by position" do
      SchoolPartner.create(school: subject, partner: partner, position: 1)
      SchoolPartner.create(school: subject, partner: other_partner, position: 0)
      expect(subject.partners.first).to eql(other_partner)
      expect(subject.partners).to match_array([other_partner, partner])
    end

    it "finds all partners" do
      expect(subject.all_partners).to match([])
      subject.partners << partner
      expect(subject.all_partners).to match([partner])
      subject.school_group.partners << other_partner
      expect(subject.all_partners).to match([partner, other_partner])
      subject.partners.destroy_all
      expect(subject.all_partners).to match([other_partner])
    end
  end

end
