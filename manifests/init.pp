# == Class: serf
#
#   Downloads the serf binary from http://serfdom.io,
#   installs the appropriate init script,
#   and manages agent configuration
#
# === Parameters
#
# [*version*]
#   Specify version of serf binary to download. Defaults to '0.4.1'
#   http://serfdom.io does not currently provide a url for latest version.
#
# [*handlers_dir*]
#   Where to put the event handler scripts managed by this module.
#
# [*config_hash*]
#   Use this to populate the JSON config file for serf.
# === Examples
#
#  You can invoke this module with simply:
#
#  include serf
#
#  which is the equivalent of:
#
#  class { serf:
#    version => '0.4.1',
#    bin_dir => '/usr/local/bin'
#  }
#
# === Authors
#
# Justin Clayton <justin@claytons.net>
#
# === Copyright
#
# Copyright 2014 Justin Clayton, unless otherwise noted.
#
class serf (
  $version              = '0.6.3',
  $bin_dir              = '/usr/local/bin',
  $handlers_dir         = '/etc/serf/handlers',
  $arch                 = $serf::params::arch,
  $init_script_url      = $serf::params::init_script_url,
  $init_script_file     = $serf::params::init_script_file,
  $config_hash          = {}
) inherits serf::params {

  $download_url = "https://dl.bintray.com/mitchellh/serf/${version}_linux_${arch}.zip"

  staging::file { 'serf.zip':
    source => $download_url,
  } ->

  staging::extract { 'serf.zip':
    target  => $bin_dir,
    creates => "${bin_dir}/serf",
  } ->

  file { [$handlers_dir, '/etc/serf']:
    ensure  => directory,
  } ->

  file { $init_script_path:
    source  => $serf::params::init_script_file,
    mode    => '0755',
    notify  => Service['serf'],
  }

  file { 'config.json':
    path   => "/etc/serf/config.json",
    content => template('serf/config.json.erb'),
    notify  => Service['serf'],
  }

  service { 'serf':
    enable => true,
    ensure => running,
  }
}
