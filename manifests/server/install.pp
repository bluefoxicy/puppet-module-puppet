class puppet::server::install {
	realize File['/etc/puppet']

	realize Package[ 'puppetmaster', 'puppetmaster-passenger' ]

	realize File [ $params::pm_install_files ]
}

