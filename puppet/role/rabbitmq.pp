class rabbitmq (
  $rabbitmq_version = 'latest',  # Puoi specificare una versione specifica o 'latest' per l'ultima
  $admin_user        = 'admin',
  $admin_password    = 'admin123!',
) {
  # Installa RabbitMQ in base alla versione di Ubuntu
  package { 'rabbitmq-server':
    ensure => $rabbitmq_version,
  }

  # Abilita il plugin di gestione
  exec { 'enable_management_plugin':
    command => '/usr/sbin/rabbitmq-plugins enable rabbitmq_management',
    unless  => '/usr/sbin/rabbitmq-plugins list -E | grep rabbitmq_management',
    require => Package['rabbitmq-server'],
  }

  # Crea l'utente amministratore
  exec { 'create_admin_user':
    command => "/usr/sbin/rabbitmqctl add_user $admin_user $admin_password",
    unless  => "/usr/sbin/rabbitmqctl list_users | grep $admin_user",
    require => Package['rabbitmq-server'],
  }

  # Imposta i permessi per l'utente amministratore
  exec { 'set_admin_permissions':
    command => "/usr/sbin/rabbitmqctl set_permissions -p / $admin_user '.*' '.*' '.*'",
    require => Exec['create_admin_user'],
  }

  # Abilita l'UI di RabbitMQ
  exec { 'enable_rabbitmq_ui':
    command => "/usr/sbin/rabbitmqctl set_user_tags $admin_user management",
    require => Exec['create_admin_user'],
  }

  # Copia il tuo file di configurazione personalizzato
  # file { '/etc/rabbitmq/rabbitmq.config':
  #   ensure => present,
  #   source => 'puppet:///modules/rabbitmq/rabbitmq.config',
  #   require => Package['rabbitmq-server'],
  # }

  # Avvia e abilita il servizio RabbitMQ
  service { 'rabbitmq-server':
    ensure  => 'running',
    enable  => true,
    require => Package['rabbitmq-server'],
  }
}
