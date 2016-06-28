# == Class: haproxywp
#
# === Authors
#
# Author Name <laurent@redhat.com>
#
# === Copyright
#
# Copyright 2015 Laurent Domb
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
