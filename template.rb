##### Options #################################################################
use_devise          = yes?('Use Devise for authentication ?')
organization        = 'sogilis'
db_password         = `pwgen 8 1`
github_repo         = "http://github.com/#{organization}/#{@app_name}"
create_github_repo  = `gem search github | grep github`.present? && yes?("Create #{github_repo} and push ?")
private_repo        = yes?("Make #{github_repo} private ?") if create_github_repo
push_to_github      = create_github_repo ? false : yes?("Push to #{github_repo} ?")
heroku_url          = "http://#{@app_name}.heroku.com/"
deploy_on_heroku    = yes? "Deploy to #{heroku_url} ?"

##### Gems ####################################################################
gsub_file 'Gemfile', /gem 'sqlite3'/, "gem 'pg', :require => 'pg'"

gem 'thin'
gem 'foreman'
gem 'devise' if use_devise
gem 'param_protected'

gem 'cucumber-rails',   :group => :test
gem 'database_cleaner', :group => :test
gem 'capybara',         :group => :test

gem 'rspec-rails',          :group => [:test, :development]
gem 'factory_girl_rails',   :group => [:test, :development]
gem 'rails_best_practices', :group => [:test, :development]

gem 'rails-footnotes', :group => :development
gem 'hirb',            :group => :development
gem 'awesome_print',   :group => :development
gem 'heroku',          :group => :development if deploy_on_heroku

##### Deleted files ###########################################################
REMOVED_FILES = %w(
  app/assets/images/rails.png
  app/helpers/application_helper.rb
  config/database.yml
  public/index.html
  README
)

run "rm #{REMOVED_FILES.join(' ')}"

##### Generated files #########################################################
file 'README.md', <<MARKDOWN
# #{@app_name.titleize}

## Hacking

    foreman start

## Running tests

    bundle exec rspec
    bundle exec cucumber

MARKDOWN

append_file 'README.md', <<MARKDOWN if deploy_on_heroku
## Deploying

    git push heroku master
MARKDOWN

file 'Procfile', <<PROCFILE
web: bundle exec thin start -p $PORT
PROCFILE

file 'config/database.yml', <<YML
development:
  adapter: postgresql
  host: localhost
  database: #{@app_name}_development
  username: #{@app_name}
  password: #{db_password}
  encoding: unicode
  pool: 5
  timeout: 5000
  min_messages: warning

test: &test
  adapter: postgresql
  host: localhost
  database: #{@app_name}_test
  username: #{@app_name}
  password: #{db_password}
  encoding: unicode
  pool: 5
  timeout: 5000
  min_messages: warning

production:
  adapter: postgresql
  host: localhost
  database: #{@app_name}_test
  username: #{@app_name}
  password: #{db_password}
  encoding: unicode
  pool: 5
  timeout: 5000
  min_messages: warning
YML

##### Install #################################################################
run 'bundle install'

generate 'cucumber:install', '--rspec --capybara'
generate 'rspec:install'

##### Git #####################################################################
git :init
git :add    => '.'
git :commit => '-m "Generated project"'

if create_github_repo

  run "github config #{organization}"
  run "github create-from-local #{'--private' if private_repo}"
  run 'github config'

elsif push_to_github

  git :remote => "add origin git@github.com:#{organization}/#{@app_name}.git"
  git :push   => 'origin master'

end

##### Heroku ##################################################################
if deploy_on_heroku
  run "heroku create #{@app_name} --stack cedar"
  git :push => 'heroku master'
  run 'heroku run rake db:migrate'
end
