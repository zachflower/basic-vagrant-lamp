This is a basic LAMP setup for Vagrant 1.2.2 using Puppet.

## Vagrantfile
This file contains the basic setup for Vagrant.

There are two sections in this file that are important to us.

### Port Forwarding
The first one is the port fowarding section. It allows us to access our Vagrant box from **outside** the box. For this example, we've opened up two ports: 80 and 3306.

    config.vm.network :forwarded_port, guest: 80, host: 8080
    config.vm.network :forwarded_port, guest: 3306, host: 3307

* **Port 80** is the internal Apache port, but to access it from outside of Vagrant, you will have to use the forwarded port: 8080. Load up a browser and put in http://127.0.0.1:8080 to interact with the website on the Vagrant box.
* **Port 3306** is for the internal MySQL. We forward it to 3307 so we can access the Vagrant MySQL using external MySQL applications, such as SequelPro (http://www.sequelpro.com).

### Puppet
The second section we care about in the Vagrantfile is the Puppet configuration. Puppet allows us to automatically provision our Vagrant box with different packages and configurations for Apache, MySQL, PHP, etc.

This section tells Vagrant that the Puppet configuration file is called `default.pp` and can be found in `/puppet/manifests` folder.

    config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file  = "default.pp"
    end

For a more complete description how the Vagrantfile works, go to http://docs-v1.vagrantup.com/v1/docs/getting-started/introduction.html.

## puppet/manifests/default.pp
This file contains the default manifest for Puppet, which lets it know how to configure the Vagrant box.

There are a few things going on in here, first of which is the package listings. Since we are setting up a LAMP environment, we need to install a few things. Thankfully, Puppet makes this very easy. Whenever the Vagrant box is started or provisioned, Puppet ensures the following packages are installed:

### Puppet Packages
* mysql-client
* mysql-server
* php5
* php5-curl
* php5-mysql
* php5-cli
* apache2
* libapache2-mod-php5

### Configuration File Management
After these packages are installed, we need to ensure the configurations are consistent and usable. Using the `file` parameter, we can tell Puppet to ensure that our MySQL and Apache configuration files are always the same as the local versions of those files. In this case `puppet/files/mysql/my.cnf` and `puppet/files/apache/default` respectively.

    file { "/etc/mysql/my.cnf":
        notify => Service["mysql"],
        mode => 644,
        owner => "root",
        group => "root",
        require => Package["mysql-server"],
        source => "/vagrant/puppet/files/mysql/my.cnf"
    }

### Process Management
Puppet also ensures that Apache and MySQL are always running, using the `exec` parameter:

    service { "mysql":
        ensure => running, 
        require => Package["mysql-server"]
    }

### MySQL User Provisioning
In the case of MySQL, Puppet also has to run a shell command to ensure there is a root user with no password that can be accessed from **outside** Vagrant (in the case of SequelPro, or other MySQL clients).

    exec { "create-db-schema-and-user":
        command => "/usr/bin/mysql -uroot -e \"CREATE DATABASE IF NOT EXISTS curie; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES;\"",
        require => Service["mysql"]
    }

For more information on Puppet, check out their documentation at http://docs.puppetlabs.com/.
