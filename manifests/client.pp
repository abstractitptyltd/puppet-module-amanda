class amanda::client (
  $remote_user      = undef,
  $server           = "backup.$::domain",
  $xinetd           = true,
  $import_host_keys = false,
) {
  include amanda
  include amanda::params
  include concat::setup

  if $remote_user != undef {
    $remote_user_real = $remote_user
  } else {
    $remote_user_real = $amanda::params::user
  }

  # for systems that don't use xinetd, don't use xinetd
  if (("x$xinetd" == 'xtrue') and !$amanda::params::xinetd_unsupported) {
    realize(
      Xinetd::Service['amanda_tcp'],
      Xinetd::Service['amanda_udp'],
    )
  }

  if $amanda::params::generic_package {
    realize(Package['amanda'])
  } else {
    realize(Package['amanda/client'])
  }

  amanda::amandahosts { "amanda::client::amdump_${remote_user_real}@${server}":
    content => "${server} ${remote_user_real} amdump",
    order   => '00';
  }

  if ($import_host_keys) {
    ## export our ssh host keys
    @@sshkey { "${::clientcert}_amanda":
      ensure       => present,
      host_aliases => [$::fqdn,$::ipaddress],
      key          => $::sshrsakey,
      type         => 'ssh-rsa',
      target       => "${amanda::params::homedir}/.ssh/known_hosts",
      tag          => 'amanda_client_host_keys',
    }
  }

}
