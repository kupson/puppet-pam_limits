# Puppet module for pam_limits

class pam_limits {
   
    # Default configuration file for pam_limits.so
    $conf_file = '/etc/security/limits.conf'

    # PAM config files location
    $pam_dir   = '/etc/pam.d'

    define module_limits_so(
        $ensure = "present"
    ) {
        case $ensure {
            "present", "enable": {
                augeas {
                    "enable_limits_$name":
                        context => "/files$pam_dir/$name",
                        incl    => "$pam_dir/$name",
                        lens    => "Pam.lns",
                        onlyif  => "match *[type='session' and control='required' and module='pam_limits.so'] size < 1",
                        changes => [
                                    "ins 0 after *[label() = '#comment' and .=~ regexp('^[ \t]*session[ \t]+required[ \t]+pam_limits.so')]",
                                    "set 0/type session",
                                    "set 0/control required",
                                    "set 0/module pam_limits.so",
                                ];
                }
            }

            "absent", "disable": {
                augeas {
                    "enable_limits_$name":
                        context => "/files$pam_dir/$name",
                        incl    => "$pam_dir/$name",
                        lens    => "Pam.lns",
                        onlyif  => "match *[type='session' and control='required' and module='pam_limits.so'] size > 0",
                        changes => "rm *[type='session' and control='required' and module='pam_limits.so']";
                }
            }

            default: {
                fail("enable_limits unknown ensure value")
            }
        }
    }

    module_limits_so{[ 'login', 'su', 'cron', 'sshd' ]:
      ensure => 'present';
    }

}

define pam_limit(
        $ensure = "present",
        $domain,
        $type   = "-",
        item,
        $value  = 0
) {

    case $ensure {
        "present" ,"enable": {
            augeas {
                "$name":
                    context => "/files${pam_limits::conf_file}",
                    incl    => "${pam_limits::conf_file}",
                    lens    => "Limits.lns",
                    changes => [
                      "set domain[.='$domain' and type='$type' and item='$item'] '$domain'",
                      "set domain[type='$type' or count(type)=0]/type '$type'",
                      "set domain[item='$item' or count(item)=0]/item '$item'",
                      "set domain[.='$domain' and type='$type' and item='$item']/value '$value'",
                      ],
            }
        }

        "absent", "disable": {
            augeas {
                "$name":
                    context => "/files${pam_limits::conf_file}",
                    incl    => "${pam_limits::conf_file}",
                    lens    => "Limits.lns",
                    onlyif  => "match domain[.='$domain' and type='$type' and item='$item'] size > 0",
                    changes => "rm domain[.='$domain' and type='$type' and item='$item']";
            }
        }

        default: {
            fail("pam_limit unknown ensure value")
        }
    }

}
