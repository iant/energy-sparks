require 'rails_helper'

describe EstimatedAnnualConsumption, type: :model do

  let(:school)          { create(:school) }

  context "when validating" do
    it "should require year" do
      estimate = EstimatedAnnualConsumption.new({school: school, electricity: 10.0})
      expect(estimate.valid?).to be false
    end

    it "should require a least one estimate" do
      estimate = EstimatedAnnualConsumption.new({school: school, year: 2021})
      expect(estimate.valid?).to be false
    end
  end

  context "when converting to meter attributes" do

    let(:estimate)  { create(:estimated_annual_consumption, school: school, electricity: 1000.0, gas: 1500.0, storage_heaters: 500.0, year: 2021) }

    it "should generate aggregated electricity attribute" do
      attribute = MeterAttribute.to_analytics([estimate.meter_attribute_for_electricity_estimate])
      expect(attribute[:estimated_period_consumption][0][:start_date]).to eql(Date.new(2021, 1, 1))
      expect(attribute[:estimated_period_consumption][0][:end_date]).to eql(Date.new(2021, 12, 31))
      expect(attribute[:estimated_period_consumption][0][:kwh]).to eql(1000.0)
    end

    it "should generate aggregated gas attribute" do
      attribute = MeterAttribute.to_analytics([estimate.meter_attribute_for_gas_estimate])
      expect(attribute[:estimated_period_consumption][0][:start_date]).to eql(Date.new(2021, 1, 1))
      expect(attribute[:estimated_period_consumption][0][:end_date]).to eql(Date.new(2021, 12, 31))
      expect(attribute[:estimated_period_consumption][0][:kwh]).to eql(1500.0)
    end

    it "should generate aggregated storage attribute" do
      attribute = MeterAttribute.to_analytics([estimate.meter_attribute_for_storage_heaters_estimate])
      expect(attribute[:estimated_period_consumption][0][:start_date]).to eql(Date.new(2021, 1, 1))
      expect(attribute[:estimated_period_consumption][0][:end_date]).to eql(Date.new(2021, 12, 31))
      expect(attribute[:estimated_period_consumption][0][:kwh]).to eql(500.0)
    end

    it "should generate all attributes when provided" do
      attributes = estimate.meter_attributes_by_meter_type
      expect(attributes[:aggregated_electricity]).to_not be_empty
      expect(attributes[:aggregated_gas]).to_not be_empty
      expect(attributes[:storage_heater_aggregated]).to_not be_empty
    end

  end
end
