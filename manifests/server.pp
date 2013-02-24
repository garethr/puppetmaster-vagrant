Exec {
  path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
}

class {'ruby':
  gems_version => 'latest'
}

apt::source {'puppetlabs-repo':
  location => 'http://apt.puppetlabs.com',
  key      => '4BD6EC30',
}

package {'puppet':
  ensure  => installed,
  require => Apt::Source['puppetlabs-repo'],
}

file { '/etc/puppet/autosign.conf':
  ensure  => present,
  content => '*',
  require => Package['puppet'],
}

class {'puppet::server':
  servertype         => 'standalone',
  manifest           => '/etc/puppet/manifests/site.pp',
  modulepath         => '/etc/puppet/modules',
  ca                 => true,
  report             => false,
  reports            => [],
  config_version_cmd => '',
  require            => File['/etc/puppet/autosign.conf'],
  monitor_server     => false,
}

package {'puppetdb':
  ensure => installed,
  require => Apt::Source['puppetlabs-repo'],
}

service {'puppetdb':
  ensure     => running,
  enable     => true,
  hasstatus  => true,
  hasrestart => true,
  require    => [
    Package['puppetdb'],
    Exec['/usr/sbin/puppetdb-ssl-setup'],
  ]
}

file_line { 'puppetdb-host':
  path    => '/etc/puppetdb/conf.d/jetty.ini',
  line    => 'host = 0.0.0.0',
  require => Package['puppetdb'],
  notify  => Service['puppetdb'],
}

file_line { 'puppetdb-repl':
  path    => '/etc/puppetdb/conf.d/repl.ini',
  line    => 'enabled = true',
  match   => '^enabled = .*$',
  require => Package['puppetdb'],
  notify  => Service['puppetdb'],
}

package {'puppetdb-terminus':
  ensure  => installed,
  require => Class['puppet::server'],
}

file {'/etc/puppet/puppetdb.conf':
  ensure  => present,
  content => "[main]\nserver = puppet\nport = 8081\n",
  require => Class['puppet::server'],
}

concat::fragment { 'puppet.conf-storedconfigs':
  order   => '10',
  target  => $puppet::params::puppet_conf,
  content => "\nstoreconfigs = true\nthin_storeconfigs = true\nstoreconfigs_backend = puppetdb\n",
  require => Class['puppet::server'],
}

concat::fragment { 'puppet.conf-serialization':
  order   => '11',
  target  => $puppet::params::puppet_conf,
  content => "\npreferred_serialization_format = yaml\n",
  require => Class['puppet::server'],
}

concat::fragment { 'puppet.conf-lastrun':
  order   => '12',
  target  => $puppet::params::puppet_conf,
  content => "\nlastrunfile = \$statedir/last_run_summary.yaml { mode = 644 }\n",
  require => Class['puppet::server'],
}

exec { 'restart_puppet_master':
  command => '/etc/init.d/puppetmaster restart',
  require => [
    Concat::Fragment['puppet.conf-storedconfigs'],
    Concat::Fragment['puppet.conf-serialization'],
    Concat::Fragment['puppet.conf-lastrun'],
  ]
}

exec { '/usr/sbin/puppetdb-ssl-setup':
  creates => '/etc/puppetdb/ssl/keystore.jks',
  require => Exec['restart_puppet_master'],
}
