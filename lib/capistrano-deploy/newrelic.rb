require 'new_relic/recipes'
module CapistranoDeploy
  module Newrelic
    def self.load_into(configuration)
      configuration.load do

        set(:api_key) { ENV['NEW_RELIC_API_KEY'] }
        set(:app_name) { ENV['NEW_RELIC_APP_NAME'] }
        set(:user) { capture("users").chomp }
        set(:current_revision) { capture("cd #{deploy_to} && git rev-parse HEAD").chomp }
        set(:link) { "https://api.newrelic.com/deployments.xml" }

        namespace :newrelic do

          task :notice_deployment do
            run "curl -H '#{api_key}' -d 'deployment[app_name]=#{app_name}' -d 'deployment[revision]=#{current_revision}' -d 'deployment[user]=#{user}' #{link}"
          end
        end

        after 'unicorn:reexec', 'newrelic:notice_deployment'
      end
    end
  end
end