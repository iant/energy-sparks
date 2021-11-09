module Onboarding
  class OnboardingListener
    def school_made_visible(school)
      ActivationEmailSender.new(school).send
    end
  end
end
