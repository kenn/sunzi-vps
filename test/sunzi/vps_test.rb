require 'test_helper'

class Sunzi::VpsTest < Minitest::Test
  def setup
    # @pwd = Dir.pwd
    # Dir.chdir GemRoot.join('test/project')

    FileUtils.rm_rf GemRoot.join('linode')
  end

  def teardown
    # Dir.chdir @pwd

    FileUtils.rm_rf GemRoot.join('linode')
  end

  def test_vps_init
    assert_output(/go ahead and edit/) do
      Sunzi::Vps::Init.new.run('linode')
    end
    assert Dir.exist?('linode')
    assert File.exist?('linode/linode.yml')
  end
end
