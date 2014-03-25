require 'new_relic/recipes'
module CapistranoDeploy
  module Newrelic
    def self.load_into(configuration)
      configuration.load do
        namespace :newrelic do

          task :notice_deployment do
            #run "curl -H 'eecea6ff70c4296b9dc0d8ff1761c8354e4a41e9d559404:eecea6ff70c4296b9dc0d8ff1761c8354e4a41e9d559404' -d 'deployment[app_name]=Your Account' https://api.newrelic.com/deployments.xml"
            run "curl -H 'eecea6ff70c4296b9dc0d8ff1761c8354e4a41e9d559404:eecea6ff70c4296b9dc0d8ff1761c8354e4a41e9d559404' -d 'deployment[application_id]=2936733' -d 'deployment[description]=This deployment was sent using curl' -d 'deployment[revision]=1242' -d 'deployment[changelog]=many hands make light work' -d 'deployment[user]=Ruben Estevez' https://api.newrelic.com/deployments.xml"
          end
        end

        after 'unicorn:reexec', 'newrelic:notice_deployment'
      end
    end
  end
end