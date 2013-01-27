class puppet::client::install {
  realize File['/etc/puppet']

  package { 'puppet':
    ensure  => present,
    require => Class['puppet::repository'],
    before  => File['/etc/puppet'],
  }
}
