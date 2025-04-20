require 'fastlane/action'
require_relative '../helper/match_envfile_helper'
require 'tmpdir'
require 'openssl'
require 'digest'
require 'fileutils'

module Fastlane
  module Actions
    class MatchEnvfileAction < Action
      def self.run(params)
        repo_url = params[:git_url]
        repo_branch = params[:git_branch]
        repo_basic_authorization = Base64.decode64(params[:git_basic_authorization])
        environment = params[:environment]
        readonly = params[:readonly]
        password = params[:password]

        project_root = Dir.pwd

        if project_root.include?("ios")
          project_root = project_root.gsub("/ios", "")
        end

        if project_root.include?("android")
          project_root = project_root.gsub("/android", "")
        end
        
        split_repo_url = repo_url.split("https://")
        repo_url = split_repo_url[1]
        git_url = "https://#{repo_basic_authorization}@#{repo_url}"

        Dir.mktmpdir do |dir|
          system("git clone #{git_url} #{dir}", chdir: dir)
          system("cd #{dir} && git checkout #{repo_branch}", chdir: dir)
          if readonly
            envfile = File.read(dir + "/secrets/.env." + environment)
            decoded = Base64.strict_decode64(envfile)
            iv = decoded[0..15]                        # First 16 bytes = IV
            encrypted = decoded[16..-1]                # Rest = encrypted content

            cipher = OpenSSL::Cipher.new('aes-256-cbc')
            cipher.decrypt
            cipher.key = Digest::SHA256.digest(password)
            cipher.iv = iv

            envfile = cipher.update(encrypted) + cipher.final
            File.write(project_root + "/.env." + environment, envfile)
            FileUtils.rm_rf(dir)
          end

            envfile = File.read(project_root + "/.env." + environment)
            cipher = OpenSSL::Cipher.new('aes-256-cbc')
            cipher.encrypt

            key = Digest::SHA256.digest(password) # derive key from password
            iv = cipher.random_iv

            cipher.key = key
            cipher.iv = iv

            encrypted = cipher.update(envfile) + cipher.final

            encrypted_envfile = Base64.strict_encode64(iv + encrypted)

            FileUtils.mkdir_p(dir + '/secrets')

            File.write(dir + '/secrets/.env.' + environment, encrypted_envfile)

            system("git add .", chdir: dir)
            system("git commit -m 'Add .env.#{environment}'", chdir: dir)
            system("git push origin #{repo_branch}", chdir: dir)
            FileUtils.rm_rf(dir)
        end
        
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
          FastlaneCore::ConfigItem.new(key: :environment  ,
                                  env_name: "MATCH_ENVFILE_ENVIRONMENT",
                               description: "Defines the environment to be used e.g. 'development', 'staging', 'production'",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :readonly,
                                  env_name: "MATCH_ENVFILE_READONLY",
                               description: "Defines if you want to read or write to the .env file",
                                  optional: true,
                                      type: Boolean),
          FastlaneCore::ConfigItem.new(key: :password,
                                  env_name: "MATCH_PASSWORD",
                               description: "The password to be used to encrypt/decrypt the .env file",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :git_url,
                                  env_name: "MATCH_GIT_URL",
                               description: "The URL of the GitHub repository to be used to store the .env file",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :git_basic_authorization,
                                  env_name: "MATCH_GIT_BASIC_AUTHORIZATION",
                               description: "The basic authorization to be used to access the GitHub repository",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :git_branch,
                                  env_name: "MATCH_GIT_BRANCH",
                               description: "The branch to be used to store or read the .env file",
                                  optional: true,
                                      type: String)

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
