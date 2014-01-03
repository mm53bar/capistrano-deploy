module CapistranoDeploy
  module Environment
    def self.load_into(configuration)
      configuration.load do

        set(:environment_file) { ".env" }

        namespace :environment do
          desc "Copy ENV file from remote git repository to your staging/production servers"
          task :fetch_config, :roles => :app, :except => {:no_release => true} do
            path_to_new_env = File.join deploy_to, "tmp", "env_config", app_name, ".env.#{current_stage}"
            path_to_old_env = File.join deploy_to, environment_file

            run "rm -rf #{deploy_to}/tmp/env_config && git clone -n #{environment_repository} --depth 1 #{deploy_to}/tmp/env_config"
            run "cd #{deploy_to}/tmp/env_config && git checkout HEAD #{app_name}/.env.#{current_stage}"

            lines_changed = capture("diff #{path_to_new_env} #{path_to_old_env} | wc -l").chomp.to_i

            if lines_changed > 0 && /^y/i =~ Capistrano::CLI.ui.ask("Do you wish to override the existing .env file (y/n)? ")
              run "cp #{path_to_new_env}  #{path_to_old_env}"
            end

          end

          desc "Fetch ENV file from remote git repository to your local machine"
          task :fetch_config_locally do
            raise "Not yet implemented"
          end
        end

        after 'deploy:setup', 'environment:fetch_config'
      end
    end
  end
end