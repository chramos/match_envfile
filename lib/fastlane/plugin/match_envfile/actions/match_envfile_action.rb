require 'fastlane/action'
require_relative '../helper/match_envfile_helper'

module Fastlane
  module Actions
    class MatchEnvfileAction < Action
      def self.run(params)
        UI.message("The match_envfile plugin is working! #{params}")
      end

      def self.description
        "Easily sync your environment variables across your team"
      end

      def self.authors
        ["Henrique Ramos"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "This Fastlane plugin provides a secure and convenient way to manage .env files across your team by leveraging a private GitHub repository, inspired by the proven workflow of Fastlane’s match. Designed to simplify environment configuration for iOS and Android projects, it ensures your team always has access to the correct environment variables without the need for manual setup or insecure sharing."
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "MATCH_ENVFILE_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
