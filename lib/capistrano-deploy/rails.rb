module CapistranoDeploy
  module Rails
    def self.load_into(configuration)
      configuration.load do
        set :rake do
          if using_recipe?(:bundle)
            'bundle exec rake'
          else
            'rake'
          end
        end

        set(:rails_env) { 'production' }

        namespace :deploy do
          desc 'Deploy & migrate'
          task :migrations do
            update
            migrate
            restart
          end

          desc 'Run migrations'
          task :migrate, :roles => :db, :only => {:primary => true} do
            run "cd #{deploy_to} && RAILS_ENV=#{rails_env} #{rake} db:migrate"
          end

          desc 'Run seeds'
          task :seed, :roles => :db, :only => {:primary => true} do
            run "cd #{deploy_to} && RAILS_ENV=#{rails_env} #{rake} db:seed"
          end

          desc 'Create tmp directories'
          task :tmp, :roles => :app do
            run "mkdir -p #{deploy_to}/tmp/pids"
            run "mkdir -p #{deploy_to}/tmp/sockets"
          end
        end
      end
    end
  end
end
