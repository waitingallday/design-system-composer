require 'rubygems'
require 'bundler'

Bundler.require(:default, :development)

require File.expand_path('../app', __FILE__)
run App.app
