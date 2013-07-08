class init {
	exec { "apt-get-update":
		command => "/usr/bin/apt-get update ; apt-get -f -y install"
	}

	package { [ "vim", "git", "mysql-client", "php5", "php5-curl", "php5-mysql", "php5-cli", "curl", "apache2", "libapache2-mod-php5", "mysql-server" ] :
		ensure => present,
		require => Exec["apt-get-update"]
	}

	service { "apache2":
		ensure => running,
		require => Package["apache2"],
	}

	exec { "/usr/sbin/a2enmod rewrite":
		notify => Service["apache2"],
		require => Package["apache2"]
	}

	file { "/etc/apache2/sites-available/default":
		notify => Service["apache2"],
		mode => 644,
		owner => "root",
		group => "root",
		require => Package["apache2"],
		source => "/vagrant/puppet/files/apache/default"
	}

	service { "mysql":
		ensure => running, 
		require => Package["mysql-server"]
	}

	exec { "create-db-schema-and-user":
		command => "/usr/bin/mysql -uroot -e \"CREATE DATABASE IF NOT EXISTS curie; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES;\"",
		require => Service["mysql"]
	}

	file { "/etc/mysql/my.cnf":
		notify => Service["mysql"],
		mode => 644,
		owner => "root",
		group => "root",
		require => Package["mysql-server"],
		source => "/vagrant/puppet/files/mysql/my.cnf"
	}
}

include init

