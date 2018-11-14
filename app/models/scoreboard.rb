# == Schema Information
#
# Table name: scoreboards
#
#  created_at  :datetime         not null
#  description :string
#  id          :bigint(8)        not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  updated_at  :datetime         not null
#

class Scoreboard < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: [:finders, :slugged, :history]

  has_many :school_groups
  has_many :schools, through: :school_groups

  validates :name, presence: true

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Scoreboard has associated groups' if school_groups.any?
    destroy
  end
end
