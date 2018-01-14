module Sunzi
  module Vps
    class Init
      include Sunzi::Utility
      include Sunzi::Actions::Delegate

      delegate_to_thor :empty_directory, :template

      def run(provider)
        config_path = "#{provider}/#{provider}.yml"
        return if File.exist? config_path

        empty_directory "#{provider}/instances"
        template "templates/#{provider}.yml", config_path
        exit_with "Now go ahead and edit #{provider}.yml"
      end
    end
  end
end
