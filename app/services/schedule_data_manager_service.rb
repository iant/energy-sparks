require 'dashboard'

class ScheduleDataManagerService
  def initialize(school)
    @calendar_id = school.calendar_id
    @temperature_area_id = school.weather_underground_area_id
    @solar_irradiance_area_id = school.weather_underground_area_id
    @solar_pv_tuos_area_id = school.solar_pv_tuos_area_id
    @dark_sky_area_id = school.dark_sky_area_id
  end

  def holidays
    cache_key = "#{@calendar_id}-holidays"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      hol_data = HolidayData.new

      Calendar.find(@calendar_id).holidays.order(:start_date).map do |holiday|
        hol_data << SchoolDatePeriod.new(:holiday, holiday.title, holiday.start_date, holiday.end_date)
      end

      Holidays.new(hol_data)
    end
  end

  def process_feed_data(output_data, area_id, feed_type)
    data_feed = Area.find(area_id).data_feed

    query = <<-SQL
      SELECT date_trunc('day', at) AS day, array_agg(value ORDER BY at ASC) AS values
      FROM data_feed_readings
      WHERE feed_type = #{DataFeedReading.feed_types[feed_type]}
      AND data_feed_id = #{data_feed.id}
      GROUP BY date_trunc('day', at)
      ORDER BY day ASC
    SQL

    result = ActiveRecord::Base.connection.execute(query)
    result.each do |row|
      output_data.add(Date.parse(row["day"]), row["values"].delete('{}').split(',').map(&:to_f))
    end
    output_data
  end

  def temperatures
    ENV['DARK_SKY_FOR_TEMPERATURES'] ? dark_sky_temperatures : weather_underground_temperatures
  end

  def solar_irradiation
    cache_key = "#{@solar_irradiance_area_id}-solar-irradiation"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      data = SolarIrradiance.new('solar irradiance')
      process_feed_data(data, @solar_irradiance_area_id, :solar_irradiation)
    end
  end

  def solar_pv
    cache_key = "#{@solar_pv_tuos_area_id}-solar-pv-2-tuos"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      data = SolarPV.new('solar pv')

      DataFeeds::SolarPvTuosReading.where(area_id: @solar_pv_tuos_area_id).pluck(:reading_date, :generation_mw_x48).each do |date, values|
        data.add(date, values.map(&:to_f))
      end
      data
    end
  end

  def co2
    cache_key = "co2-feed"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      uk_grid_carbon_intensity_data = GridCarbonIntensity.new
      DataFeeds::CarbonIntensityReading.all.pluck(:reading_date, :carbon_intensity_x48).each do |date, values|
        uk_grid_carbon_intensity_data.add(date, values.map(&:to_f))
      end
      CO2Parameterised.fill_in_missing_uk_grid_carbon_intensity_data_with_parameterised(uk_grid_carbon_intensity_data)
      uk_grid_carbon_intensity_data
    end
  end

private

  def weather_underground_temperatures
    cache_key = "#{@temperature_area_id}-weather-underground-temperatures"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      data = Temperatures.new('temperatures')
      process_feed_data(data, @temperature_area_id, :temperature)
    end
  end

  def dark_sky_temperatures
    cache_key = "#{@dark_sky_area_id}-dark-sky-temperatures"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      data = Temperatures.new('temperatures')

      DataFeeds::DarkSkyTemperatureReading.where(area_id: @dark_sky_area_id).pluck(:reading_date, :temperature_celsius_x48).each do |date, values|
        data.add(date, values.map(&:to_f))
      end
      data
    end
  end
end
