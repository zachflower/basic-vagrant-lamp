This is a basic LAMP setup for Vagrant 1.2.2 using Puppet.

## Vagrantfile
This file contains the basic setup for Vagrant.

There are two sections in this file that are important to us.

### Port Forwarding
The first one is the port fowarding section. It allows us to access our Vagrant box from *outside* the box. For this example, we've opened up two ports: 80 and 3306.

* Port 80 is the internal Apache port, but to access it from outside of Vagrant, you will have to use the forwarded port: 8080. Load up a browser and put in http://127.0.0.1:8080 to interact with the website on the Vagrant box.
* Port 3306 is for the internal MySQL. We forward it to 3307 so we can access the Vagrant MySQL using external MySQL applications, such as SequelPro (http://www.sequelpro.com).

### Puppet
The second section we care about in the Vagrantfile is the Puppet configuration. Puppet allows us to automatically provision our Vagrant box with different packages and configurations for Apache, MySQL, PHP, etc.

This section tells Vagrant that the Puppet configuration file is called *default.pp* and can be found in */puppet/manifests* folder.

    config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file  = "default.pp"
    end

For a more complete description how the Vagrantfile works, go to http://docs-v1.vagrantup.com/v1/docs/getting-started/introduction.html.

## puppet/manifests/default.pp
