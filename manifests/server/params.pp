class puppet::server::params {
  $daemon = $::puppet::daemon
  if ( $daemon != 'webrick' and $daemon != 'passenger' ) {
    fail("Unsupported daemon $daemon")
  }

  case $osfamily {
    Debian: {
      $webserver                   = 'apache2'
      $puppetmaster_httpd_config   =
        [
          '/etc/apache2/sites-enabled/puppetmaster',
          '/etc/apache2/sites-available/puppetmaster',
        ]
      $puppetmaster_pkg            = 'puppetmaster'
      $puppetmaster_passenger_pkg  = 'puppetmaster-passenger'
      $pm_install_files            =
        [
          '/etc/apache2/sites-available/puppetmaster',
          '/etc/apache2/sites-enabled/puppetmaster',
        ]
      case $daemon {
        webrick:   { $pm_pkg_mode  = present }
        passenger: { 
          $pm_pkg_mode  = absent
          @file { '/etc/apache2/sites-available/puppetmaster':
            content  => template('puppet/puppetmaster.apache2.erb'),
            owner    => 'root',
            group    => 'root',
            mode     => '0444';
            '/etc/apache2/sites-enabled/puppetmaster':
            ensure   => 'link',
            target   => '../sites-available/puppetmaster',
            owner    => 'root',
            group    => 'root';
          }
        }
      }
    }

    Redhat: {
      $webserver                   = 'httpd'
      $puppetmaster_httpd_config   = '/etc/httpd/conf.d/puppetmaster'
      $puppetmaster_pkg            = 'puppet-server'
      $puppetmaster_passenger_pkg  = 'mod_passenger'
      # puppet-server supplies the rails rack
      $pm_pkg_mode                 = present

      $pm_install_files            =
        [
          '/etc/httpd/conf.d/puppetmaster',
          '/etc/puppet/rack',
          '/etc/puppet/rack/public',
          '/etc/puppet/rack/tmp',
          '/etc/puppet/rack/config.ru',
        ]
      if $daemon == "passenger" {
        @file { '/etc/httpd/conf.d/puppetmaster':
          source  => 'puppet:///modules/puppet/etc/apache2/sites-available/puppetmaster',
          owner   => 'root',
          group   => 'root',
          mode    => '0444';
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
          mode    => '0444';
          '/usr/share/puppet/ext/rack/files/config.ru':
          ensure  => present,
          owner   => 'puppet',
          group   => 'puppet',
          mode    => '0444',
          require => Package['puppetmaster'];
        }
      }
    } ## case Redhat
    default:  { fail("Unsupported osfamily $osfamily") }
  }

  if $daemon != 'passenger' {
    $pm_passenger_ensure = 'absent'
    @file { $pm_install_files:
      ensure  => absent,
    }
  }
  else {
    $pm_passenger_ensure = 'present'
  }

  @package { 'puppetmaster':
    name    => $puppetmaster_pkg,
    ensure  => $pm_pkg_mode,
    require => Class['puppet::repository'],
    before  => File['/etc/puppet'],
    tag     => 'puppetmaster',
  }

  @package { 'puppetmaster-passenger':
    name    => $puppetmaster_passenger_pkg,
    ensure  => $pm_passenger_ensure,
    require => Class['puppet::repository'],
    before  => File[ $pm_install_files ],
    tag     => 'puppetmaster',
  }
}
