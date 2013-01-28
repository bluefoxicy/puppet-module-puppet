class puppet::repository::puppetlabs {
  # The templates use $lsbdistcodename to fill in the repository
  # information
  case $osfamily {
    Debian: {
      file { '/etc/apt/trusted.gpg.d/puppetlabs-keyring.gpg':
        source  => "puppet:///modules/puppet/etc/apt/trusted.gpg.d/puppetlabs-keyring.gpg",
        owner   => 'root',
        group   => 'root',
	mode    => '0444';
	'/etc/apt/sources.list.d/puppetlabs.list':
	content => template('puppet/puppetlabs.list.erb'),
	owner   => 'root',
	group   => 'root',
	mode    => '0444';
      }
    }

    Redhat: {
      $osmajversion = regsubst($operatingsystemrelease, '^(\d+)(\.\d+)?', '\1')
      case $operatingsystem {
        'Fedora': { $osreleasename = 'el' }
        default:  { $osreleasename = 'fedora' }
      }

      yumrepo { 'puppetlabs-products':
	descr          => "Puppet Labs Products $osreleasename $osmajversion",
	baseurl        => "http://yum.puppetlabs.com/${osreleasename}/${osmajversion}/products/\$basearch",
	failovermethod => 'priority',
	enabled        => '1',
	gpgcheck       => '1',
	gpgkey         => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs';
        'puppetlabs-dependencies':
	descr          => "Puppet Labs Dependencies $osreleasename $osmajversion",
	baseurl        => "http://yum.puppetlabs.com/${osreleasename}/${osmajversion}/dependencies/\$basearch",
	failovermethod => 'priority',
	enabled        => '1',
	gpgcheck       => '1',
	gpgkey         => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
      }
      
    }
    default: { fail("Cannot install repos on $osfamily") }
  }
}
