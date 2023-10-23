require 'kamal_rails/version'
require 'kamal_rails/engine'

module KamalRails
  DIRECTORY = '.kamal_rails'

  def self.setup!
    # Ensure directory is set up
    directory_path = Rails.root.join(DIRECTORY)

    unless File.directory?(directory_path)
      Dir.mkdir(directory_path)
    end

    # Ensure we read the config
    KamalRails::DeployConfig.init!
  end
end
