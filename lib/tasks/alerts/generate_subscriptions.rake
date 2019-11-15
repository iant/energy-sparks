namespace :alerts do
  desc 'Run alert subscription job'
  task generate_subscriptions: [:environment] do
    puts Time.zone.now
    schools = School.process_data.visible.with_config

    schools.each do |school|
      subscription_frequency = if school.holiday_approaching?
                                 [:weekly, :termly, :before_each_holiday]
                               else
                                 [:weekly]
                               end
      puts "Running alert subscription generation for #{school.name}, including #{subscription_frequency.to_sentence} subscriptions"
      Alerts::GenerateSubscriptions.new(school).perform(subscription_frequency: subscription_frequency)
    end

    puts Time.zone.now
  end
end
