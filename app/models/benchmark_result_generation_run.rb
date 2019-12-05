# == Schema Information
#
# Table name: benchmark_result_generation_runs
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  updated_at :datetime         not null
#

class BenchmarkResultGenerationRun < ApplicationRecord
  has_many :benchmark_result_school_generation_runs
  has_many :benchmark_result_errors, through: :benchmark_result_school_generation_runs
  has_many :benchmark_results, through: :benchmark_result_school_generation_runs
end
