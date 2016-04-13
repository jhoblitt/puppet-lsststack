require 'spec_helper'

describe 'lsststack::lsstsw', :type => :define do
  let(:facts) {{ :osfamily => 'RedHat', :operatingsystemmajrelease => '6' }}
  let(:name) { 'foo' }
  let(:title) { name }
  let(:pre_condition) { 'include ::lsststack' }

  describe 'parameters' do
    context '(all unset)' do
      it { should compile.with_all_deps }
      it do
        should contain_lsststack__lsstsw(name).
          that_requires('Class[lsststack]')
      end
      it do
        should contain_user(name).with(
          :ensure     => 'present',
          :gid        => name,
          :managehome => true,
          :shell      => '/bin/bash'
        )
      end
      it do
        should contain_group(name).with(
          :ensure => 'present'
        )
      end
      it do
        should contain_vcsrepo("/home/#{name}/lsstsw").with(
          :ensure   => 'present',
          :provider => 'git',
          :user     => name,
          :group    => name,
          :revision => 'master'
        )
      end
      it do
        should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
          :ensure   => 'present',
          :provider => 'git',
          :user     => name,
          :group    => name,
          :revision => 'master'
        )
      end
      it do
        should contain_exec('deploy').with(
          :creates => "/home/#{name}/lsstsw/lfs/bin/numdiff"
        ).that_requires([
          "Vcsrepo[/home/#{name}/lsstsw]",
          "Vcsrepo[/home/#{name}/buildbot-scripts]",
        ])
      end
      it do
        should contain_exec('user.name').with(
          :command => "git config -f /home/#{name}/lsstsw/versiondb/.git/config user.name \"LSST DATA Management\""
        ).that_requires('Exec[deploy]')
      end
      it do
        should contain_exec('user.email').with(
          :command => "git config -f /home/#{name}/lsstsw/versiondb/.git/config user.email \"dm-devel@lists.lsst.org\""
        ).that_requires('Exec[deploy]')
      end
      it do
        should contain_vcsrepo("/home/#{name}/lsstsw/lsst_build").with(
          :ensure   => 'present',
          :provider => 'git',
          :user     => name,
          :group    => name,
          :revision => 'master'
        ).that_requires('Exec[deploy]')
      end
      it do
        should contain_exec('rebuild -p').
          that_requires([
            'Exec[user.name]',
            'Exec[user.email]',
          ]).
          that_subscribes_to([
            'Exec[deploy]',
            "Vcsrepo[/home/#{name}/lsstsw/lsst_build]"
          ])
      end
    end # default params

    context 'user =>' do
      context '(unset)' do
        it { should contain_lsststack__lsstsw(name).with(:user => name) }
        it { should contain_user(name) }
      end

      context 'larry' do
        let(:params) {{ :user => 'larry' }}

        it { should contain_user('larry') }
      end

      context '[]' do
        let(:params) {{ :user => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # user =>

    context 'group =>' do
      context '(unset)' do
        it { should contain_lsststack__lsstsw(name).with(:group => name) }
        it { should contain_group(name) }
      end

      context 'larry' do
        let(:params) {{ :group => 'larry' }}

        it { should contain_group('larry') }
      end

      context '[]' do
        let(:params) {{ :group => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # group =>

    context 'manage_user =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(:manage_user => true)
        end
        it { should contain_user(name) }
      end

      context 'true' do
        let(:params) {{ :manage_user => true }}

        it { should contain_user(name) }
      end

      context 'false' do
        let(:params) {{ :manage_user => false }}

        it { should_not contain_user(name) }
      end

      context 'bar' do
        let(:params) {{ :manage_user => 'bar' }}

        it { should raise_error(Puppet::Error, /is not a bool/) }
      end
    end # manage_user =>

    context 'manage_group =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(:manage_group => true)
        end
        it { should contain_group(name) }
      end

      context 'true' do
        let(:params) {{ :manage_group => true }}

        it { should contain_group(name) }
      end

      context 'false' do
        let(:params) {{ :manage_group => false }}

        it { should_not contain_group(name) }
      end

      context 'bar' do
        let(:params) {{ :manage_group => 'bar' }}

        it { should raise_error(Puppet::Error, /is not a bool/) }
      end
    end # manage_group =>

    context 'lsstsw_path =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :lsstsw_path => nil
          )
        end
        it { should contain_vcsrepo("/home/#{name}/lsstsw") }
      end

      context '/dne' do
        let(:params) {{ :lsstsw_path => '/dne' }}

        it { should contain_vcsrepo("/dne/lsstsw") }
      end

      context 'foo' do
        let(:params) {{ :lsstsw_path => 'foo' }}

        it { should raise_error(Puppet::Error, /is not an absolute path/) }
      end
    end # lsstsw_path =>

    context 'lsstsw_repo =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :lsstsw_repo => 'https://github.com/lsst/lsstsw.git'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/lsstsw").with(
            :source => 'https://github.com/lsst/lsstsw.git'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :lsstsw_repo => 'bar' }}

        it do
          should contain_vcsrepo("/home/#{name}/lsstsw").with(
            :source => 'bar'
          )
        end
      end

      context '[]' do
        let(:params) {{ :lsstsw_repo => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # lsstsw_repo =>

    context 'lsstsw_branch =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :lsstsw_branch => 'master'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/lsstsw").with(
            :revision => 'master'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :lsstsw_branch => 'bar' }}

        it do
          should contain_vcsrepo("/home/#{name}/lsstsw").with(
            :revision => 'bar'
          )
        end
      end

      context '[]' do
        let(:params) {{ :lsstsw_branch => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # lsstsw_branch =>

    context 'lsstsw_ensure =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :lsstsw_ensure => 'present'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/lsstsw").with(
            :ensure => 'present'
          )
        end
      end

      context 'present' do
        let(:params) {{ :lsstsw_ensure => 'present' }}

        it do
          should contain_vcsrepo("/home/#{name}/lsstsw").with(
            :ensure => 'present'
          )
        end
      end

      context 'latest' do
        let(:params) {{ :lsstsw_ensure => 'latest' }}

        it do
          should contain_vcsrepo("/home/#{name}/lsstsw").with(
            :ensure => 'latest'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :lsstsw_ensure => 'bar' }}

        it { should raise_error(Puppet::Error, /does not match/) }
      end
    end # lsstsw_ensure =>

    context 'buildbot_repo =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :buildbot_repo => 'https://github.com/lsst-sqre/buildbot-scripts.git'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
            :source => 'https://github.com/lsst-sqre/buildbot-scripts.git'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :buildbot_repo => 'bar' }}

        it do
          should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
            :source => 'bar'
          )
        end
      end

      context '[]' do
        let(:params) {{ :buildbot_repo => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # buildbot_repo =>

    context 'buildbot_branch =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :buildbot_branch => 'master'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
            :revision => 'master'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :buildbot_branch => 'bar' }}

        it do
          should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
            :revision => 'bar'
          )
        end
      end

      context '[]' do
        let(:params) {{ :buildbot_branch => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # buildbot_branch =>

    context 'buildbot_ensure =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :buildbot_ensure => 'present'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
            :ensure => 'present'
          )
        end
      end

      context 'present' do
        let(:params) {{ :buildbot_ensure => 'present' }}

        it do
          should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
            :ensure => 'present'
          )
        end
      end

      context 'latest' do
        let(:params) {{ :buildbot_ensure => 'latest' }}

        it do
          should contain_vcsrepo("/home/#{name}/buildbot-scripts").with(
            :ensure => 'latest'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :buildbot_ensure => 'bar' }}

        it { should raise_error(Puppet::Error, /does not match/) }
      end
    end # buildbot_ensure =>

    context 'lsst_build_repo =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :lsst_build_repo => 'https://github.com/lsst/lsst_build.git'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/lsstsw/lsst_build").with(
            :source => 'https://github.com/lsst/lsst_build.git'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :lsst_build_repo => 'bar' }}

        it do
          should contain_vcsrepo("/home/#{name}/lsstsw/lsst_build").with(
            :source => 'bar'
          )
        end
      end

      context '[]' do
        let(:params) {{ :lsst_build_repo => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # lsst_build_repo =>

    context 'lsst_build_branch =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :lsst_build_branch => 'master'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/lsstsw/lsst_build").with(
            :revision => 'master'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :lsst_build_branch => 'bar' }}

        it do
          should contain_vcsrepo("/home/#{name}/lsstsw/lsst_build").with(
            :revision => 'bar'
          )
        end
      end

      context '[]' do
        let(:params) {{ :lsst_build_branch => [] }}

        it { should raise_error(Puppet::Error, /is not a string/) }
      end
    end # lsst_build_branch =>

    context 'lsst_build_ensure =>' do
      context '(unset)' do
        it do
          should contain_lsststack__lsstsw(name).with(
            :lsst_build_ensure => 'present'
          )
        end
        it do
          should contain_vcsrepo("/home/#{name}/lsstsw/lsst_build").with(
            :ensure => 'present'
          )
        end
      end

      context 'present' do
        let(:params) {{ :lsst_build_ensure => 'present' }}

        it do
          should contain_vcsrepo("/home/#{name}/lsstsw/lsst_build").with(
            :ensure => 'present'
          )
        end
      end

      context 'latest' do
        let(:params) {{ :lsst_build_ensure => 'latest' }}

        it do
          should contain_vcsrepo("/home/#{name}/lsstsw/lsst_build").with(
            :ensure => 'latest'
          )
        end
      end

      context 'bar' do
        let(:params) {{ :lsst_build_ensure => 'bar' }}

        it { should raise_error(Puppet::Error, /does not match/) }
      end
    end # lsst_build_ensure =>

    context 'debug =>' do
      context '(unset)' do
        it { should contain_lsststack__lsstsw(name).with(:debug => false) }
      end

      context 'true' do
        let(:params) {{ :debug => true }}

        it { should_not raise_error }
      end

      context 'false' do
        let(:params) {{ :debug => false }}

        it { should_not raise_error }
      end

      context 'bar' do
        let(:params) {{ :debug => 'bar' }}

        it { should raise_error(Puppet::Error, /is not a bool/) }
      end
    end # debug =>
  end # on osfamily RedHat
end
