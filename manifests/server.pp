class puppet::server {
  $daemon    = $::puppet::daemon
  include puppet::server::params
  $webserver = $::puppet::server::params::webserver

	case $daemon {
	 webrick:	{
		$pm_ensure		= running
		$pm_enable		= true
	 }
	 passenger: {
		$pm_ensure		= stopped
		$pm_enable		= false
		service { 'puppetmaster-passenger':
			name		=> $webserver,
			ensure		=> running,
			enable		=> true,
			hasstatus	=> true,
			hasrestart	=> true,
			require		=> [
						Class['puppet::server::install'],
						Class['puppet::config'],
					   ],
			subscribe	=> File['/etc/puppet/puppet.conf'];
		}
	 }
	 default:	{ fail("Unsupported daemon $daemon") }
	}

	include puppet::server::install

	service { 'puppetmaster':
		ensure		=> $pm_ensure,
		enable		=> $pm_enable,
		hasstatus	=> true,
		hasrestart	=> true,
		subscribe	=> File['/etc/puppet/puppet.conf'];
	}
}

