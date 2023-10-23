# frozen_string_literal: true

require 'yaml'

module Deployed
  # Provides a model to track the current values in ./config/deploy.yml
  class Config < ActiveSupport::CurrentAttributes
    attribute :service, :image, :servers, :ssh, :volumes, :registry, :env, :traefik, :requires_init, :env_values

    def self.init!(yaml_file = './config/deploy.yml', dot_env_file = '.env')
      self.requires_init = File.exist?(yaml_file) ? false : true

      unless requires_init
        yaml_data = YAML.load_file(yaml_file)
        self.service = yaml_data['service']
        self.image = yaml_data['image']
        self.servers = yaml_data['servers']
        self.ssh = yaml_data['ssh']
        self.volumes = yaml_data['volumes']
        self.registry = yaml_data['registry']
        self.env = yaml_data['env'] || {}
        self.traefik = yaml_data['traefik']
      end

      if File.exist?(dot_env_file)
        self.env_values = {}

        File.open(dot_env_file, 'r') do |file|
          file.each_line do |line|
            key, value = line.strip.split('=')
            self.env_values[key] = value
          end
        end
      end

      requires_init
    end
  end
end
