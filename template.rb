REMOVED_FILES = %w(
  public/index.html
  app/assets/images/rails.png
  app/helpers/application_helper.rb
  README
)

run "rm #{REMOVED_FILES.join(' ')}"

file 'README.md', <<-MD
# #{@app_name.titleize}

## Hacking

    foreman start

## Running tests

    bundle exec rspec
    bundle exec cucumber

## Deploying

    git push heroku

MD

gem 'pg', :require => 'pg'

gem 'thin'
gem 'foreman'
gem 'devise'
gem 'param_protected'

gem 'cucumber-rails',       :group => :test
gem 'database_cleaner',     :group => :test
gem 'capybara',             :group => :test
gem 'rspec-rails',          :group => [:test, :development]
gem 'factory_girl_rails',   :group => [:test, :development]
gem 'rails_best_practices', :group => [:test, :development]

gem 'rails-footnotes', :group => :development
gem 'hirb',            :group => :development
gem 'awesome_print',   :group => :development

gem 'heroku', :group => :development

run 'bundle install'

generate 'cucumber:install', '--rspec --capybara'
generate 'rspec:install'

git :init
git :add => '.'
git :commit => '-m "Generated project using Sogilis Rails template"'

if yes? "Push to http://github.com/sogilis/#{@app_name} ?"
  git :remote => "add origin git@github.com:sogilis/#{@app_name}.git"
  git :push => 'origin master'
end

if yes? 'Deploy to http://#{@app_name}.heroku.com/ ?'
  run "heroku create #{@app_name} --stack cedar"
  git :push => 'heroku master'
end
