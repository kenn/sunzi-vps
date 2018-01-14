$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sunzi/vps'

require 'minitest/autorun'

require 'webmock/minitest'

GemRoot = Pathname.new(__FILE__).dirname.parent

require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr'
  c.hook_into :webmock
  c.filter_sensitive_data('<API_KEY>') { YAML.load(GemRoot.join('test/project/linode/linode.yml').read)['api_key'] }
end

class Object
  alias_method :exit_without_throw, :exit

  def exit(*args)
    throw :exit
  rescue UncaughtThrowError
    # Occurs at the end of test run itself
    exit_without_throw
  end

  def abort(*args)
    throw :abort
  end
end
