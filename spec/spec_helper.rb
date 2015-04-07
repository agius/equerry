require 'bundler'
Bundler.setup

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'equerry'

require 'json'
require 'logger'

def fixture(name)
  path = File.join(File.expand_path(File.dirname(__FILE__)), 'fixtures', "#{name}.json")
  JSON.parse(File.read(path))
end

FIXTURES = {
  mizuguchi: fixture('mizuguchi'),
  sakurai:   fixture('sakurai'),
  suda:      fixture('suda')
}