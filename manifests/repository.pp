class puppet::repository::load {
	# The templates use $lsbdistcodename to fill in the repository
	# information
	case $osfamily {
	 Debian: {
		file { '/etc/apt/trusted.gpg.d/puppetlabs-keyring.gpg':
			source	=> "puppet:///modules/puppet/etc/apt/trusted.gpg.d/puppetlabs-keyring.gpg",
			owner	=> root,
			group	=> root,
			mode	=> 0444;
		'/etc/apt/sources.list.d/puppetlabs.list':
			content	=> template('puppet/puppetlabs.list.erb'),
			owner	=> root,
			group	=> root,
			mode	=> 0444;
		}
	 }
	 Redhat: {
		fail('FIXME:  Use $osfamily to detect RHEL--where do the GPG keys and yum.repos.d files go precisely?')
	 }
	 default: { fail("Cannot install repos on $osfamily") }
	}
}

class puppet::repository(
	$repository	= 'puppetlabs',
) {

	case $repository {
	 puppetlabs:	{ include puppet::repository::load }
	 distro:	{ }
	 default:	{ fail("Invalid reposource $reposource") }
	}
}
