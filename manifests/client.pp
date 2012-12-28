class puppet::client {
	include	puppet::client::install

	service { 'puppet':
		ensure		=> running,
		hasstatus	=> true,
		hasrestart	=> true,
		enable		=> true,
		require		=> [
					Class['puppet::client::install'],
					Class['puppet::config'],
				   ],
		subscribe	=> File['/etc/puppet/puppet.conf'],
	}
}
