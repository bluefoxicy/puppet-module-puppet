class puppet::server {
  $daemon    = $::puppet::daemon

  case $daemon {
    webrick: {
      service { 'puppetmaster':
        ensure      => running,
        enable      => true,
        hasstatus   => true,
        hasrestart  => true,
      }
      File <| tag == 'puppet-config' |> ~>
      Service['puppetmaster']
    }
    passenger: {
      include puppet::server::passenger
    }
    unicorn: {
      include puppet::server::unicorn
    }
    default: { fail("Unsupported daemon $daemon") }
  }
}

