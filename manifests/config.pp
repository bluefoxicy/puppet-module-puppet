class puppet::config {
  $servername   = $::puppet::servername
  $environment  = $::puppet::environment
  $environments = $::puppet::environments
  $logdir       = '/var/log/puppet'
  $vardir       = '/var/lib/puppet'
  $ssldir       = '$vardir/ssl'
  $rundir       = '/var/run/puppet'

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
