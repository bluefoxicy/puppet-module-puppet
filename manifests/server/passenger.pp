class puppet::server::passenger {
  $pm_ensure		= stopped
  $pm_enable		= false
  case $osfamily {
    Debian: {
      $webserver    = 'apache2'
      $pm_pkg_mode  = absent
      $puppetmaster_pkg            = 'puppetmaster'
      $puppetmaster_passenger_pkg  = 'puppetmaster-passenger'
      @file { '/etc/apache2/sites-available/puppetmaster':
        content  => template('puppet/puppetmaster.apache2.erb'),
        owner    => 'root',
        group    => 'root',
        mode     => '0444',
        tag     => 'puppet-config';
        '/etc/apache2/sites-enabled/puppetmaster':
        ensure   => 'link',
        target   => '../sites-available/puppetmaster',
        owner    => 'root',
        group    => 'root',
        tag     => 'puppet-config';
      }
    }

    Redhat: {
      $webserver                   = 'httpd'
      $puppetmaster_pkg            = 'puppet-server'
      $puppetmaster_passenger_pkg  = 'mod_passenger'
      # puppet-server supplies the rails rack
      $pm_pkg_mode                 = present

      file { '/etc/httpd/conf.d/puppetmaster':
        content  => template('puppet/puppetmaster.apache2.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        tag     => 'puppet-config';
        '/etc/puppet/rack':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0644';
        [
          '/etc/puppet/rack/public',
          '/etc/puppet/rack/tmp',
        ]:
        ensure  => directory,
        owner   => 'root',
        group   => 'puppet',
        mode    => '0664';
        '/etc/puppet/rack/config.ru':
        ensure  => link,
        target  => '/usr/share/puppet/ext/rack/files/config.ru',
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0444',
        tag     => 'puppet-config';
        '/usr/share/puppet/ext/rack/files/config.ru':
        ensure  => present,
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0444',
        require => Package['puppetmaster'],
        tag     => 'puppet-config';
      }
    } ## case Redhat
    default:  { fail("Unsupported osfamily $osfamily") }
  }

  package { 'puppetmaster':
    name    => $puppetmaster_pkg,
    ensure  => $pm_pkg_mode,
    require => Class['puppet::repository'],
    before  => File['/etc/puppet'],
    tag     => 'puppetmaster',
  }

  package { 'puppetmaster-passenger':
    name    => $puppetmaster_passenger_pkg,
    ensure  => present,
    require => Class['puppet::repository'],
    tag     => 'puppetmaster',
  }

  service { 'puppetmaster':
    ensure      => stopped,
    enable      => false,
    hasstatus   => true,
    hasrestart  => true,
    tag         => 'puppetmaster',
  }

  service { 'puppetmaster-passenger':
    name        => $webserver,
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    tag         => 'puppetmaster',
  }

  Package <| tag == 'puppetmaster' |> ->
  Class ['puppet::config']            ->
  Service ['puppetmaster-passenger']

  Package <| tag == 'puppetmaster' |> ->
  File <| tag == 'puppet-config' |>   ~>
  Service['puppetmaster-passenger']

  Service['puppetmaster']             ->
  Service['puppetmaster-passenger']
}
