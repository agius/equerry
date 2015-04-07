require 'bundler'
Bundler.setup

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'equerry'

require 'json'
require 'logger'

FIXTURES = {}

def fixture(name)
  return FIXTURES[name] if FIXTURES[name]
  path = File.join(File.expand_path(File.dirname(__FILE__)), 'fixtures', "#{name}.json")
  JSON.parse(File.read(path))
end

def index(*args)
  args.each do |arg|
    document = nil
    document = arg if arg.is_a?(Hash)
    document ||= fixture(arg)
    Equerry.index(body: document)
  end
  Equerry.refresh
end