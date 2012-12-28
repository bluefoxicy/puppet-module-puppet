class puppet::server(
	$daemon	= 'passenger',
) {
	class { puppet::server::params:
		daemon	=> $daemon,
	}

	case $daemon {
	 webrick:	{
		$pm_ensure		= running
		$pm_enable		= true
	 }
	 passenger: {
		$pm_ensure		= stopped
		$pm_enable		= false
		service { 'puppetmaster-passenger':
			name		=> $::puppet::server::params::webserver,
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

