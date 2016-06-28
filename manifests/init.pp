# == Class: haproxywp
#
# Full description of class haproxywp here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { haproxywp:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class haproxywp (
    $foreman_url   = "",
    $foreman_user  = "",
    $foreman_pass  = "",

) {

  $gce = { item  => 'fact_values',
    search       => "(name = gce_public_ipv4 or name = gce_public_hostname) and host !~ ${hostname}",
    per_page     => '20',
    foreman_url  => $foreman_url,
    foreman_user => $foreman_user,
    foreman_pass => $foreman_pass }

  $rhev = { item => 'fact_values',
    search       => '(name = rhev_public_ipv4 or name = rhev_public_hostname)',
    per_page     => '20',
    foreman_url  => $foreman_url,
    foreman_user => $foreman_user,
    foreman_pass => $foreman_pass }

  $ec2 = { item  => 'fact_values',
    search       => '(name = ec2_public_ipv4 or name = ec2_public_hostname) and host ~ %\.ec2\.internal',
    per_page     => '20',
    foreman_url  => $foreman_url,
    foreman_user => $foreman_user,
    foreman_pass => $foreman_pass }

  $gcehosts  = foreman($gce)
  $ec2hosts  = foreman($ec2)
  $rhevhosts = foreman($rhev)

  file {'/etc/haproxy/haproxy.cfg':
        content => template('haproxywp/haproxy.cfg.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        require => Package['haproxy'],
        notify  => Service['haproxy'];
  }

  package {'haproxy':
        ensure => present,
  }

  service { 'haproxy':
      ensure  => running,
      enable  => true,
      require => Package['haproxy'];
  }
}
