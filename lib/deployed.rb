require 'deployed/version'
require 'deployed/engine'

module Deployed
  DIRECTORY = '.deployed'

  def self.setup!
    # Ensure directory is set up
    directory_path = Rails.root.join(DIRECTORY)

    unless File.directory?(directory_path)
      Dir.mkdir(directory_path)
    end

    # Ensure we read the config
    Deployed::Config.init!
  end
end
