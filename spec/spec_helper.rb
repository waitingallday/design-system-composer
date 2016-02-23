$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'rubygems'

require 'bundler'
Bundler.require(:default, :development)
Dotenv.load

require './app.rb'
require 'minitest/autorun'

if ENV['COVERAGE']
  require 'coverage'
  require 'simplecov'

  def SimpleCov.roda_coverage(_opts = {})
    start do
      add_filter '/spec/'
      add_group('Missing') { |src| src.covered_percent < 100 }
      add_group('Covered') { |src| src.covered_percent == 100 }
      yield self if block_given?
    end
  end

  ENV.delete('COVERAGE')
  SimpleCov.roda_coverage
end

require 'stringio'
require 'minitest/autorun'

#
class Minitest::Spec
  def app(type = nil, &block)
    case type
    when :new
      @app = _app { route(&block) }
    when :bare
      @app = _app(&block)
    when Symbol
      @app = _app do
        plugin type
        route(&block)
      end
    else
      @app ||= _app { route(&block) }
    end
  end

  def req(path = '/', env = {})
    if path.is_a?(Hash)
      env = path
    else
      env['PATH_INFO'] = path.dup
    end

    env = {
      'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/', 'SCRIPT_NAME' => ''
    }.merge(env)
    @app.call(env)
  end

  def status(path = '/', env = {})
    req(path, env)[0]
  end

  def header(name, path = '/', env = {})
    req(path, env)[1][name]
  end

  def body(path = '/', env = {})
    s = ''
    b = req(path, env)[2]
    b.each { |x| s << x }
    b.close if b.respond_to?(:close)
    s
  end

  def _app(&block)
    c = Class.new(App)
    c.class_eval(&block)
    c
  end

  def with_rack_env(env)
    ENV['RACK_ENV'] = env
    yield
  ensure
    ENV.delete('RACK_ENV')
  end
end
