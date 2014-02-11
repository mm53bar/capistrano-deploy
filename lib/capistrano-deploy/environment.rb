module CapistranoDeploy
  module Environment
    def self.load_into(configuration)
      configuration.load do

        set(:environment_file) { ".env" }

        namespace :environment do

          namespace :servers do
            desc "Copy ENV file from remote git repository to your staging/production servers"
            task :fetch_config, :roles => :app, :except => {:no_release => true} do

              if /^y/i =~ Capistrano::CLI.ui.ask("Do you wish to override the existing #{environment_file} file (y/n)? ")

              path_to_new_env = File.join deploy_to, "tmp", "env_config", app_name, ".env.#{current_stage}"
              path_to_old_env = File.join deploy_to, environment_file

              run "rm -rf #{deploy_to}/tmp/env_config && git clone -n #{environment_repository} --depth 1 #{deploy_to}/tmp/env_config"
              run "cd #{deploy_to}/tmp/env_config && git checkout HEAD #{app_name}/.env.#{current_stage}"
              run "cp #{path_to_new_env}  #{path_to_old_env}"
              else
                puts "Config not changed"
              end
            end

            task :verify do
              run "ssh-keyscan #{environment_host} | tee --append $HOME/.ssh/known_hosts"
            end

          end

          namespace :local do
            desc "Fetch ENV file from remote git repository to your local machine"
            task :fetch_config do
              if /^y/i =~ Capistrano::CLI.ui.ask("Do you wish to override the existing #{environment_file} file (y/n)? ")
                temp_folder = Rails.root.join('tmp', 'env_config')
                run_locally "rm -rf #{temp_folder} && git clone -n #{environment_repository} --depth 1 #{temp_folder}"
                run_locally "cd #{temp_folder} && git checkout HEAD #{app_name}/.env.*"
                run_locally "cp #{app_name}/.env.* #{Rails.root}"
                run_locally "cp #{Rails.root}/.env.development #{Rails.root}/.env"
              else
                puts "Environmental files not updated."
              end
            end
          end

          after 'deploy:setup', 'environment:servers:verify'
          after 'environment:servers:verify', 'environment:servers:fetch_config'

        end

      end
    end
  end
end