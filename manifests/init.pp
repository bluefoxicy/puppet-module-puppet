class puppet(
	$mode		= 'client',
	$daemon		= 'passenger',
	$repository	= 'distro',
	$environment	= 'production',
	$environments	= '',
	$server,
) {

	@file { '/etc/puppet':
		ensure	=> directory,
		owner	=> root,
		group	=> root,
		mode	=> 0644,
	}

	class { puppet::repository:
		repository	=> $repository,
	}

	case $mode {
	 client: {
		include puppet::client
	 }
	 server: {
		include	 puppet::client
		class { puppet::server:
			daemon	=> $daemon,
		}
	 }
	 default: { fail("Invalid mode $mode") }
	}

	class { puppet::config:
		server		=> $server,
		environment	=> $environment,
		environments	=> $environments,
	}
}
