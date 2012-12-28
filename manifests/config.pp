class puppet::config(
	$logdir		= '/var/log/puppet',
	$vardir		= '/var/lib/puppet',
	$ssldir		= '$vardir/ssl',
	$rundir		= '/var/run/puppet',
	$environment	= 'production',
	$environments	= '',
	$server		= '',
) {
	if $server == '' {
		fail("puppet::config must be passed a value server => 'puppet.example.com'.")
	}
	file { '/etc/puppet/puppet.conf':
		content	=> template('puppet/puppet.conf.erb'),
		owner	=> root,
		group	=> root,
		mode	=> 0444,
	}

	case $osfamily {
	 debian: {
		file { '/etc/default/puppet':
			source	=> 'puppet:///modules/puppet/etc/default/puppet',
			owner	=> root,
			group	=> root,
			mode	=> 0444,
		}
	 }
	}
}
