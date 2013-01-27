class puppet::params(
  $server       = 'disabled',
  $environment  = 'production',
  $environments = [ 'dev', 'testing', 'production' ],
  $daemon       = 'webrick',
  $repository   = 'distro',
) {

}
