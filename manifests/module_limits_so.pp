define pam_limits::module_limits_so(
  $ensure = 'present'
) {
  case $ensure {
    'present', 'enable': {
      augeas{"enable_limits_$name":
        context => "/files${::pam_limits::pam_dir}/$name",
        incl    => "${::pam_limits::pam_dir}/$name",
        lens    => 'Pam.lns',
        onlyif  => 'match *[type=\'session\' and control=\'required\' and module=\'pam_limits.so\'] size < 1',
        changes => [
          "ins 0 after *[label() = '#comment' and .=~ regexp('^[ \t]*session[ \t]+required[ \t]+pam_limits.so')]",
          'set 0/type session',
          'set 0/control required',
          'set 0/module pam_limits.so',
          ],
      }
    }

    'absent', 'disable': {
      augeas {
        "enable_limits_$name":
          context => "/files${::pam_limits::pam_dir}/$name",
          incl    => "${::pam_limits::pam_dir}/$name",
          lens    => 'Pam.lns',
          onlyif  => 'match *[type=\'session\' and control=\'required\' and module=\'pam_limits.so\'] size > 0',
          changes => 'rm *[type=\'session\' and control=\'required\' and module=\'pam_limits.so\']',
      }
    }

    default: {
      fail('enable_limits unknown ensure value')
    }
  }
}

