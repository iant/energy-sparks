# == Schema Information
#
# Table name: data_feeds
#
#  area_id       :integer
#  configuration :hstore           not null
#  description   :text
#  id            :bigint(8)        not null, primary key
#  title         :text
#  type          :text             not null
#

class DataFeeds::WeatherUnderground < DataFeed
end
