module CapistranoDeploy
  module Campfire
    def self.load_into(configuration)
      configuration.load do
        namespace :campfire do
          require 'campy'

          desc 'Set notification in campfire for deployment start'
          task :start_msg do
            campy = Campy::Room.new(account: campfire_account, token: campfire_token, room_id: campfire_room_id)
            campy.speak "#{campfire_speaker.chomp} is starting deploy of '#{app_name.upcase}' from branch '#{branch}' to #{current_stage.upcase}"
          end

          desc 'Set notification in campfire for deployment end'
          task :end_msg do
            campy = Campy::Room.new(account: campfire_account, token: campfire_token, room_id: campfire_room_id)
            campy.speak "Deployment of '#{app_name.upcase}' from branch '#{branch}' to #{current_stage.upcase} was successful!"
            campy.play "pushit"
          end
        end

        before 'deploy:update', 'campfire:start_msg'
        after 'unicorn:reexec', 'campfire:end_msg'
      end
    end
  end
end