source 'https://rubygems.org'

ruby '2.5.1'

# Rails/Core
gem 'rails', '~> 5.1.0' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'puma' # Use Puma as the app server
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder

# Database/Data
gem 'pg' # Use postgresql as the database for Active Record
gem 'soda-ruby', :require => 'soda' # For the Socrata Open Data API

# Assets
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'jquery-ui-rails' # Use jquery UI for datepickers
gem 'sass-rails'# Use SCSS for stylesheets
gem 'uglifier' # Use Uglifier as compressor for JavaScript assets

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Frontend
gem 'bootstrap', '~> 4.1.0' # Use bootstrap for responsive layout
gem 'chartkick' # Use chartkick for usage graphs
gem 'redcarpet' # Use redcarpet to convert markdown
gem "font-awesome-rails" # Fonts
gem "highcharts-rails"

# JS Templating
gem 'handlebars_assets'

# User input
gem 'trix' # Use Trix editor for activity descriptions

# Auth & Users
gem 'devise' # Use devise for authentication
gem 'cancancan' # Use cancancan for authorization

# Utils
gem 'groupdate' # Use groupdate to group usage stats
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'whenever', :require => false # Provides a syntax for writing and deploying cron jobs
gem 'dotenv-rails' # Shim to load environment variables from .env into ENV in development.
gem 'friendly_id' # Pretties up URLs
gem 'merit', '3.0.0' # Reputation/achievements/rankings

# Email service
gem 'mailgun_rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem "bullet" # use bullet to optimise queries
  gem 'rspec-rails', '~> 3.5'
  gem 'rails-controller-testing'
  gem "fakefs", require: "fakefs/safe"
  gem 'factory_bot_rails'
  gem 'climate_control'
  gem 'webmock'
  gem 'vcr'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'annotate'
  gem 'pry'
  gem 'govuk-lint', '1.2.1' # Use govuk-lint to install Rubocop and Cops that correspond to the GDS Styleguide https://github.com/alphagov/govuk-lint
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'simplecov', :require => false, :group => :test
end

#Capistrano gems
group :development do
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
end
