module CapistranoDeploy
  module Campfire
    def self.load_into(configuration)
      configuration.load do
        namespace :campfire do
          require 'campy'
          env = Dotenv.load '.env'
          campy = Campy::Room.new(account: env['CAMPFIRE_ACCOUNT'], token: env['CAMPFIRE_TOKEN'], room_id: env['CAMPFIRE_ROOM_ID'])

          desc 'Set notification in campfire for deployment start'
          task :start_msg do
            campy.speak "#{`whoami`.upcase} is starting deploy of '#{app_name.upcase}' from branch '#{branch}' to #{current_stage.upcase}"
          end

          desc 'Set notification in campfire for deployment end'
          task :end_msg do
            campy.speak "Deployment of '#{app_name.upcase}' from branch '#{branch}' to #{current_stage.upcase} was successful!"
            campy.play "pushit"
          end
        end

        before 'deploy:update', 'campfire:start_msg'
        after 'deploy:update', 'campfire:end_msg'
      end
    end
  end
end