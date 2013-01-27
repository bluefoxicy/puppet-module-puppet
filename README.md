puppet-module-puppet
====================

A module to control Puppet

TODO:
  - Unicorn/nginx support
  - Eventually use nginx/apache modules for vhost configuration
  - PuppetDB support

try putting the following...

/etc/puppet/environments/production/manifests/sites.pp:

```puppet
import 'nodes/*'
```

/etc/puppet/environments/production/manifests/nodes/puppetmaster.example.com:

```puppet
node 'puppetmaster.example.com' {
  class { puppet:
    servername    => 'puppetmaster.example.com',
    server        => enabled,
    daemon        => 'passenger',
    repository    => 'puppetlabs',
    environments  => [ 'dev', 'testing', 'production' ],
  }
}
```

Obviously, you want to start with your manifests directory in the given location.  Here is an example default puppet config that will bootstrap puppet:


```config
[main]
logdir = /var/log/puppet
vardir = /var/lib/puppet
ssldir = $vardir/ssl
rundir = /var/run/puppet

modulepath = $confdir/environments/$environment/modules:$confdir/modules
manifest = $confdir/manifests/unknown_environment.pp

factpath=$vardir/lib/facter
# These only show up on Debianites...
prerun_command = /etc/puppet/etckeeper-commit-pre
postrun_command = /etc/puppet/etckeeper-commit-post

server = puppet.example.com

[agent]
environment=production

# Environments, all using the same manifests dir
[production]
manifestdir = $confdir/environments/$environment/manifests
manifest = $confdir/environments/$environment/manifests/site.pp

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN 
ssl_client_verify_header = SSL_CLIENT_VERIFY
certname = puppet.example.com
```

