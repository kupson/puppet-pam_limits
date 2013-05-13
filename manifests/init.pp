# Puppet module for pam_limits

class pam_limits(
  $conf_file = '/etc/security/limits.conf',
  $pam_dir   = '/etc/pam.d'
) {
  module_limits_so{['login', 'su', 'cron', 'sshd']:
    ensure => 'present';
  }
}

