require 'rubygems'
require 'bundler'

Bundler.require(:default, :development)

Dotenv.load

require File.expand_path('../app', __FILE__)
run App.app
