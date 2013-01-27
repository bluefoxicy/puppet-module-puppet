class puppet::server::install {
  realize File['/etc/puppet']

  Package <| tag == 'puppetmaster' |>

  realize File [ $params::pm_install_files ]
}

