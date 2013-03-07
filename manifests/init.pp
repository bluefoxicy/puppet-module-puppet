class puppet(
  $servername,
  $server               = $puppet::params::server,
  $clientservice        = $puppet::params::clientservice,
  $environment          = $puppet::params::environment,
  $environments         = $puppet::params::environments,
  $daemon               = $puppet::params::daemon,
  $repository           = $puppet::params::repository,
  $storedconfigs        = $puppet::params::storedconfigs,
  $thin_storedconfigs   = $puppet::params::storedconfigs,
) inherits puppet::params {

  if ( $servername == '' ) {
    fail('Must set servername => puppetmaster.example.com')
  }
  @file { '/etc/puppet':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 0644,
  }

  include puppet::repository
  include puppet::client
  if ( $server == 'enabled' ) {
    include puppet::server
  }
  include puppet::config
}
