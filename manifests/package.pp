# == Class: beaver::package
#
# This class installs the beaver package and init scripts.
# It should not be directly called
#
#
# === Parameters
#   None
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
#
# === Copyright
#
# Copyright 2013 EvenUp.
#
class beaver::package (
  $venv           = $beaver::venv,
  $package_name   = $beaver::package_name,
  $provider       = $beaver::package_provider,
  $python_version = $beaver::python_version,
  $version        = $beaver::version,
  $user           = $beaver::user,
  $group          = $beaver::group,
  $home           = $beaver::home,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }


  if ($::osfamily == 'RedHat') {
    case $::lsbmajdistrelease {
      '5': {
        if !defined(Package['python26-distribute']) {
          package {'python26-distribute': }
        }
        exec {'easy_install pip':
          require => Package['python26-distribute'],
          command => '/usr/bin/easy_install-2.6 pip',
          creates => '/usr/bin/pip',
        }
      }
      '6': {
        $beaver_packages = [ "conf_d", "Beaver", "glob2", "redis", "msgpack-pure" ]
        yumrepo { "beaver":
          baseurl => "http://repo.i.bitbit.net/rhel6/beaver-x86_64/RPMS.beaver",
          descr => "beaver for el6",
          enabled => 1,
          gpgcheck => 0
        }
        # python packages have insane names. redis? you mean python-redis, etc.
        package { $beaver_packages:
          require => Yumrepo["beaver"];
        }
      }
    }
  }
  else {
    if !defined(Package['python-docutils']) {
      package {'python-docutils': }
    }
    if !defined(Package['python-pip']) {
      package {'python-pip': }
    }
  }
  package { $package_name:
    ensure   => $version,
    provider => $provider,
    notify   => Class['beaver::service'],
  }

  case $::operatingsystem {
    'CentOS', 'Fedora', 'Scientific', 'RedHat', 'Amazon': {
      $os = 'redhat'
    }
    'Debian', 'Ubuntu': {
      $os = 'debian'
    }
    default: {
      fail("no initscript for ${::operatingsystem}")
    }
  }

  file { '/etc/init.d/beaver':
    ensure  => file,
    mode    => '0555',
    content => template("beaver/beaver.init.${os}.erb"),
  }

  file { '/etc/beaver':
    ensure => 'directory',
    mode   => '0555',
  }

  file { '/etc/beaver/conf.d':
    ensure  => 'directory',
    mode    => '0555',
    purge   => true,
    force   => true,
    recurse => true,
    notify  => Class['beaver::service'],
  }

}
