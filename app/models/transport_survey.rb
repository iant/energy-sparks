# == Schema Information
#
# Table name: transport_surveys
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  run_on     :date             not null
#  school_id  :bigint(8)        not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_transport_surveys_on_run_on     (run_on) UNIQUE
#  index_transport_surveys_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class TransportSurvey < ApplicationRecord
  belongs_to :school
  has_many :responses, class_name: 'TransportSurveyResponse', inverse_of: :transport_survey

  validates :run_on, :school_id, presence: true
  validates :run_on, uniqueness: { scope: :school_id }

  def to_param
    run_on.to_s
  end

  # We will need to do something more robust than this!
  def responses=(responses_attributes)
    responses_attributes.each do |response_attributes|
      self.responses.create_with(response_attributes).find_or_create_by(response_attributes.slice(:run_identifier, :surveyed_at))
    end
  end
end
