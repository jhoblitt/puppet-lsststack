require 'spec_helper'

describe 'lsststack', :type => :class do

  describe 'for osfamily RedHat' do
    let(:facts) {{ :osfamily => 'RedHat' }}
    [
      'bison',
      'curl',
      'blas',
      'bzip2-devel',
      'bzip2', # needed on el7 -- pulled in by bzip2-devel on el6?
      'flex',
      'fontconfig',
      'freetype-devel',
      'gcc-c++',
      'gcc-gfortran',
      'git', # needed on el6, in @core for others?
      'libuuid-devel',
      'libXext',
      'libXrender',
      'libXt-devel',
      'make',
      'openssl-devel',
      'patch',
      'perl',
      'readline-devel',
      'zlib-devel',
      # needed by lua
      'ncurses-devel',
      # needed for xrootd build
      'cmake',
      # needed for mysqlproxy
      'glib2-devel',
      # needed to build zookeeper
      'java-1.7.0-openjdk',
      # needed to build git
      'gettext',
      'libcurl-devel',
      'perl-ExtUtils-MakeMaker',
    ].each do |pkg|
      it { should contain_package(pkg) }
    end
  end

  describe 'for osfamily Debian' do
    let(:facts) {{ :osfamily => 'Debian' }}
    [
      'make',
      # list from https://confluence.lsstcorp.org/display/LSWUG/Prerequisites
      'bison',
      'curl',
      'ca-certificates', # needed by curl on ubuntu
      'flex',
      'g++',
      'git',
      'libbz2-dev',
      'libreadline6-dev',
      'libx11-dev',
      'libxt-dev',
      'm4',
      'zlib1g-dev',
      # needed for shapelet tests
      'libxrender1',
      'libfontconfig1',
      # needed by lua
      'libncurses5-dev',
      # needed for xrootd build
      'cmake',
      # needed for mysqlproxy
      'libglib2.0-dev',
      # needed to build zookeeper
      'openjdk-7-jre',
      # needed to build git
      'gettext',
      'libcurl4-openssl-dev',
      'perl-modules',
    ].each do |pkg|
      it { should contain_package(pkg) }
    end
  end
end
