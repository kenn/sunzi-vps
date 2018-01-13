module Sunzi
  module Vps
    class Init
      include Sunzi::Worker::Delegate

      delegate_to_worker :copy_file, :template, :get, :append_to_file

      def run(provider)
        config_path = "#{provider}/#{provider}.yml"
        return if File.exist? config_path

        empty_directory "#{provider}/instances"
        template "templates/#{provider}.yml", config_path
        exit_with "Now go ahead and edit #{provider}.yml, then run this command again!"
      end
    end
  end
end
