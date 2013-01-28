class puppet::repository {
  $repository = $::puppet::repository
  case $repository {
    puppetlabs: { include puppet::repository::puppetlabs }
    distro:     { }
    default:    { fail("Invalid reposource $reposource") }
  }
}
