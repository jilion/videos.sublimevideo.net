$LOAD_PATH.unshift("#{Dir.pwd}/app")
Dir['app/**/'].each do |dir|
  path = "#{Dir.pwd}/#{dir}"
  $LOAD_PATH.unshift(path)
end

ENV['RAILS_ENV'] ||= 'test'

unless defined?(Rails)
  require 'rails/railtie'
  module Rails
    def self.root; Pathname.new(File.expand_path('')); end
    def self.env; 'test'; end
  end
end

unless defined?(Librato)
  module Librato
    def self.method_missing(*args)
      true
    end
  end
end

require 'bundler/setup'
require_relative 'config/rspec'
