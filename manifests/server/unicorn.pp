class puppet::server::unicorn {
  case $osfamily {
    Debian: {
      $webserver    = 'nginx'
      $pm_pkg_mode  = absent
      $puppetmaster_pkg            = 'puppetmaster'
      $puppetmaster_passenger_pkg  = 'puppetmaster-passenger'

      file { '/etc/nginx/sites-available/puppetmaster':
        content  => template('puppet/puppetmaster.nginx.conf.erb'),
        owner    => 'root',
        group    => 'root',
        mode     => '0444',
        tag      => 'puppet-config',
      }

      file { '/etc/nginx/sites-enabled/puppetmaster':
        ensure   => 'link',
        target   => '../sites-available/puppetmaster',
        owner    => 'root',
        group    => 'root',
        tag      => 'puppet-config',
      }
    }

    Redhat: {
      $webserver                   = 'nginx'
      $puppetmaster_pkg            = 'puppet-server'
      # puppet-server supplies the rails rack
      $pm_pkg_mode                 = present

      file { '/etc/nginx/conf.d/puppetmaster':
        content => template('puppet/puppetmaster.nginx.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        tag     => 'puppet-config',
      }
    } ## case Redhat
    default:  { fail("Unsupported osfamily $osfamily") }
  }

  file {
    [
      '/etc/puppet/public',
      '/etc/puppet/tmp',
    ]:
    ensure  => directory,
    owner   => 'root',
    group   => 'puppet',
    mode    => '0775',
  }

  file { '/etc/puppet/config.ru':
    ensure  => link,
    target  => '/usr/share/puppet/ext/rack/files/config.ru',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0444',
    tag     => 'puppet-config',
  }

  file { '/usr/share/puppet/ext/rack/files/config.ru':
    ensure  => present,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0444',
    require => Package['puppetmaster'],
    tag     => 'puppet-ruby',
  }

  file { '/etc/god':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    tag     => 'god-config',
  }

  file { '/etc/god/puppetmaster.god':
    ensure  => present,
    source  => 'puppet:///modules/puppet/etc/god/puppetmaster.god',
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    tag     => 'god-config',
  }

  file { '/etc/init.d/god':
    ensure  => present,
    source  => 'puppet:///modules/puppet/etc/init.d/god',
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    tag     => 'god-config',
  }

  file { '/etc/puppet/unicorn.conf':
    ensure  => present,
    source  => 'puppet:///modules/puppet/etc/puppet/unicorn.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    tag     => 'god-config',
  }

  package { 'puppetmaster':
    name    => $puppetmaster_pkg,
    ensure  => $pm_pkg_mode,
    require => Class['puppet::repository'],
    before  => File['/etc/puppet'],
    tag     => 'puppetmaster',
  }

  service { 'puppetmaster':
    ensure      => stopped,
    enable      => false,
    hasstatus   => true,
    hasrestart  => true,
    tag         => 'puppetmaster',
  }

  service { 'puppetmaster-god':
    name         => god,
    ensure       => running,
    enable       => true,
    hasstatus    => true,
    hasrestart   => true,
    tag          => 'puppetmaster',
  }

  service { 'puppetmaster-unicorn':
    name         => $webserver,
    ensure       => running,
    enable       => true,
    hasstatus    => true,
    hasrestart   => true,
    tag          => 'puppetmaster',
  }

  Package <| tag == 'puppetmaster' |> ->
  Class ['puppet::config']            ->
  Service ['puppetmaster-unicorn']

  File <| tag == 'puppet-config' |>   ~>
  Service ['puppetmaster-god']

  File <| tag == 'god-config' |>      ~>
  Service ['puppetmaster-god']

  Package <| tag == 'puppetmaster' |> ->
  File <| tag == 'puppet-config' |>   ~>
  Service['puppetmaster-unicorn']

  Service['puppetmaster']             ->
  Service['puppetmaster-unicorn']
}
