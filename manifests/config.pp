# == Class: beaver::config
#
# This class is responsible for configuring beaver
# It should not be directly called
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
class beaver::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/etc/beaver.conf':
    ensure  => 'file',
    mode    => '0444',
    content => template('beaver/beaver.conf.erb'),
    notify  => Class['beaver::service']
  }

}
