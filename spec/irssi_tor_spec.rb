require 'dockerspec'
require 'dockerspec/serverspec'

describe docker_build('.', tag: 'zuazo/irssi') do
  let(:home) { '/home/irssi' }

  it { should have_env 'IRSSI_HOME' => home }
  it { should have_env 'IRSSI_CONF_DIR' }
  it { should have_env 'IRSSI_SCRIPTS_DIR' }
  it { should have_user 'irssi' }
  it { should have_entrypoint '/usr/bin/irssi' }

  describe docker_build(File.dirname(__FILE__), tag: 'irssi_test') do
    describe docker_run('irssi_test', family: :alpine) do
      before(:all) { sleep 20 }

      describe package('irssi') do
        it { should be_installed }
      end

      describe user('irssi') do
        it { should exist }
        it { should have_home_directory home }
        it { should have_login_shell '/bin/sh' }
      end

      describe file('/home/irssi/.irssi') do
        it { should be_directory }
        it { should be_owned_by 'irssi' }
        it { should be_grouped_into 'irssi' }
      end

      describe file('/home/irssi/.irssi/scripts') do
        it { should be_directory }
        it { should be_owned_by 'irssi' }
        it { should be_grouped_into 'irssi' }
      end

      describe process('/usr/bin/irssi') do
        it { should be_running }
        its(:user) { should eq 'irssi' }
      end
    end
  end
end
