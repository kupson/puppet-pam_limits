define pam_limits::pam_limit(
  $domain,
  $item,
  $ensure = 'present',
  $type   = '-',
  $value  = 0
) {

  case $ensure {
    'present', 'enable': {
      augeas{$name:
        context => "/files${::pam_limits::conf_file}",
        incl    => $::pam_limits::conf_file,
        lens    => 'Limits.lns',
        changes => [
          "set domain[.='$domain' and type='$type' and item='$item'] '$domain'",
          "set domain[type='$type' or count(type)=0]/type '$type'",
          "set domain[item='$item' or count(item)=0]/item '$item'",
          "set domain[.='$domain' and type='$type' and item='$item']/value '$value'",
          ],
      }
    }

    'absent', 'disable': {
      augeas{$name:
        context => "/files${::pam_limits::conf_file}",
        incl    => $::pam_limits::conf_file,
        lens    => 'Limits.lns',
        onlyif  => "match domain[.='$domain' and type='$type' and item='$item'] size > 0",
        changes => "rm domain[.='$domain' and type='$type' and item='$item']";
      }
    }

    default: {
      fail('pam_limit unknown ensure value')
    }
  }

}

