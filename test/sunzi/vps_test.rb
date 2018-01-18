require 'test_helper'

class Sunzi::VpsTest < Minitest::Test
  def test_vps_init
    assert_output(/go ahead and edit/) do
      catch :exit do
        Sunzi::Vps::Init.new.run('linode')
      end
    end
    assert Dir.exist?('linode')
    assert File.exist?('linode/linode.yml')

    FileUtils.rm_rf GemRoot.join('linode')
  end

  # Testing I/O
  # http://tommaso.pavese.me/2016/05/08/understanding-and-testing-io-in-ruby/
  #
  def test_vps_up
    @pwd = Dir.pwd
    Dir.chdir GemRoot.join('test/project')

    catch :exit do
      list = %w(production test 1 2 158 138 256 n)
      Thor::LineEditor.stub(:readline, proc { list.shift || fail('list reached at the end') }) do
        VCR.use_cassette('vps_up') do
          assert_output do
            api = Sunzi::Vps::Api.new('linode')
            api.dns.stub(:verify, nil) do
              api.compute.up
            end
          end
        end
      end
    end

  ensure
    Dir.chdir @pwd
  end
end
