class puppet::client {
  include puppet::client::install
  $clientservice = $::puppet::clientservice
  if $clientservice == 'enabled' {
    $svcrunning  = 'running'
    $svcenable   = true
  }
  else {
    $svcrunning  = 'stopped'
    $svcenable   = false
  }

  service { 'puppet':
    ensure     => $svcrunning,
    hasstatus  => true,
    hasrestart => true,
    enable     => $svcenable,
    require    =>
      [
        Class['puppet::client::install'],
        Class['puppet::config'],
      ],
    subscribe  => File['/etc/puppet/puppet.conf'],
  }
}
