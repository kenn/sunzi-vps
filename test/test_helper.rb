$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sunzi/vps'

require 'minitest/autorun'

require 'webmock/minitest'

require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr'
  c.hook_into :webmock
end

GemRoot = Pathname.new(__FILE__).dirname.parent

class ::Object
  def exit(*args)
    # No-op
  end

  def abort(*args)
    # No-op
  end
end
