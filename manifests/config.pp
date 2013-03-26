class puppet::config {
  $servername           = $::puppet::servername
  $server               = $::puppet::server
  $environment          = $::puppet::environment
  $environments         = $::puppet::environments
  $storedconfigs        = $::puppet::storedconfigs
  $thin_storedconfigs   = $::puppet::thin_storedconfigs
  $logdir               = '/var/log/puppet'
  $vardir               = '/var/lib/puppet'
  $ssldir               = '$vardir/ssl'
  $rundir               = '/var/run/puppet'

  file { '/etc/puppet/puppet.conf':
    content => template('puppet/puppet.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    tag     => 'puppet-config',
  }

  file { '/etc/puppet/auth.conf':
    content => template('puppet/puppet-auth.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    tag     => 'puppet-config',
  }

  file { '/etc/puppet/fileserver.conf':
    source => 'puppet:///modules/puppet/etc/puppet/fileserver.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
    tag     => 'puppet-config',
  }

  case $osfamily {
    debian: {
      file { '/etc/default/puppet':
        source => 'puppet:///modules/puppet/etc/default/puppet',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        tag     => 'puppet-config',
      }
    }
  }
}
