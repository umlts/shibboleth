Vagrant.configure("2") do |config|

    config.vm.box = "centos/7"

    # Forward Apache
	config.vm.network "forwarded_port", guest: 80, host: 5080
	config.vm.network "forwarded_port", guest: 443, host: 5443

    # Clean installer dir
    config.vm.provision "shell",
    inline: "rm -rf /home/vagrant/install",  privileged: false

    # Push installer script to VBox
    config.vm.provision "file",
    source: "./install",
    destination: "/home/vagrant/install"

    # Run installer
    config.vm.provision "shell",
    inline: "/bin/bash /home/vagrant/install/install.sh",
    privileged: true

end


