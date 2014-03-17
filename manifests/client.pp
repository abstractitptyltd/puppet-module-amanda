class amanda::client (
  $remote_user     = undef,
  $server          = "backup.$::domain",
  $xinetd          = true,
  $manage_ssh_keys = false,
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

  if ($manage_ssh_keys) {
    sshkeys::set_authorized_key {"${remote_user_real}@${server} to ${remote_user_real}@${::hostname}":
      local_user  => $remote_user_real,
      remote_user => "${remote_user_real}@${server}",
      home        => $amanda::params::homedir,
      options     => [
        'no-port-forwarding',
        'no-X11-forwarding',
        'no-agent-forwarding',
        "command=\"${amanda::params::amandad_path} -auth=ssh amdump\"",
      ],
    }
  }
}
