define amanda::disklist (
    $diskdevice,
    $dumptype,
    $ensure,
    $interface,
    $order,
    $spindle,
    $node_fqdn,
    $tag = "amanda_dle",
    ) {
    include amanda::params
    include amanda::virtual

    $config = regsubst($title, '^.*@', '')
    $disk   = regsubst($title, '@[^@]*$', '')

    validate_string($config)
    validate_string($disk)

    @@concat::fragment { "amanda::disklist/${node_fqdn}/${title}":
        ensure  => $ensure,
        target  => "${amanda::params::configs_directory}/${config}/disklist",
        order   => $order,
        content => "${node_fqdn} ${disk} ${diskdevice} ${dumptype} ${spindle} ${interface}\n",
        tag     => 'amanda_dle',
    }
}
