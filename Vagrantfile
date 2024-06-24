Vagrant.configure("2") do |config|
  # Set VM boot timeout to 300 seconds
  config.vm.boot_timeout = 300

  ### Build net-3

  # Define VM for NAT
  config.vm.define "nat" do |nat|
    nat.vm.box = "bento/oracle-9.0"
    nat.vm.hostname = "nat"
    # Configure private network for net3
    nat.vm.network "private_network", type: "dhcp", mac: "080027123456", virtualbox__intnet: "net3"
    # Configure public network for home network with static IP
    nat.vm.network "public_network", bridge: "enp0s8", dhcp: false, ip: "192.168.0.46", netmask: "255.255.255.0", broadcast: "192.168.0.255"
    nat.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end

  # Define VM for DNS server
  config.vm.define "dns" do |dns|
    dns.vm.box = "bento/oracle-9.0"
    dns.vm.hostname = "dns"
    # Configure private network for net3
    dns.vm.network "private_network", mac: "080027123457", virtualbox__intnet: "net3"
    dns.vm.provision "shell", path: "scripts/dns/setup_dns.sh"
    dns.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end

  # Define VM for DHCP server
  config.vm.define "dhcp" do |dhcp|
    dhcp.vm.box = "bento/oracle-9.0"
    dhcp.vm.hostname = "dhcp"
    dhcp.vm.network "private_network", mac: "080027123458", virtualbox__intnet: "net3"
    dhcp.vm.provision "shell", path: "scripts/dhcp/setup_dhcp.sh"
    dhcp.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end

  # Define VM for client in net3
  config.vm.define "clientNet3" do |client|
    client.vm.box = "bento/oracle-9.0"
    client.vm.hostname = "client-net3"
    # Configure private network with DHCP for net3
    client.vm.network "private_network", type: "dhcp", mac: "080027123459", virtualbox__intnet: "net3"
    client.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end

  # Define VM for router R1
  config.vm.define "R1" do |r1|
    r1.vm.box = "bento/ubuntu-22.04"
    r1.vm.hostname = "R13"
    # Configure private networks with DHCP for net3 and net1
    r1.vm.network "private_network", type: "dhcp", mac: "080027123460", virtualbox__intnet: "net3"
    r1.vm.network "private_network", type: "dhcp", mac: "080027123461", virtualbox__intnet: "net1"
    r1.vm.provision "shell", path: "scripts/routers_conf/setup_router_R13.sh"
    r1.vm.provider "virtualbox" do |v|
      v.memory = 812
      v.cpus = 1
    end
  end

  # Define VM for client in net1
  config.vm.define "client-net1" do |clientnet1|
    clientnet1.vm.box = "bento/oracle-9.0"
    clientnet1.vm.hostname = "client-net1"
    # Configure private network with DHCP for net1
    clientnet1.vm.network "private_network", type: "dhcp", mac: "080027123462", virtualbox__intnet: "net1"
    clientnet1.vm.provision "shell", inline: <<-SHELL
      #!/bin/bash
      ip route delete default via 10.0.2.2 dev eth0
    SHELL
    clientnet1.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end

  # Define VM for router R2
  config.vm.define "R2" do |r2|
    r2.vm.box = "bento/oracle-9.0"
    r2.vm.hostname = "R23"
    # Configure private networks with DHCP for net3 and net2
    r2.vm.network "private_network", type: "dhcp", mac: "080027123463", virtualbox__intnet: "net3"
    r2.vm.network "private_network", type: "dhcp", mac: "080027123464", virtualbox__intnet: "net2"
    r2.vm.provision "shell", path: "scripts/routers_conf/setup_router_R13.sh"
    r2.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end

  # Define VM for client in net2
  config.vm.define "client-net2" do |clientnet2|
    clientnet2.vm.box = "bento/ubuntu-22.04"
    clientnet2.vm.hostname = "client-net2"
    # Configure private network with DHCP for net2
    clientnet2.vm.network "private_network", type: "dhcp", mac: "080027123465", virtualbox__intnet: "net2"
    clientnet2.vm.provider "virtualbox" do |v|
      v.memory = 768
      v.cpus = 1
    end
  end

  # Define VM for router Rdmz
  config.vm.define "Rdmz" do |rdmz3|
    rdmz3.vm.box = "bento/ubuntu-22.04"
    rdmz3.vm.hostname = "Rdmz3"
    # Configure private networks with DHCP for net3 and net-dmz
    rdmz3.vm.network "private_network", type: "dhcp", mac: "080027123466", virtualbox__intnet: "net3"
    rdmz3.vm.network "private_network", type: "dhcp", mac: "080027123467", virtualbox__intnet: "net-dmz"
    rdmz3.vm.provision "shell", path: "scripts/routers_conf/setup_router_Rdmz3.sh"
    rdmz3.vm.provider "virtualbox" do |v|
      v.memory = 768
      v.cpus = 1
    end
  end

  # Define VM for nginx server 1 in net-dmz
  config.vm.define "nginx-1" do |nginx1|
    nginx1.vm.box = "bento/ubuntu-22.04"
    nginx1.vm.hostname = "nginx-1"
    # Configure private network with DHCP for net-dmz
    nginx1.vm.network "private_network", type: "dhcp", mac: "080027123468", virtualbox__intnet: "net-dmz"
    nginx1.vm.provider "virtualbox" do |v|
      v.memory = 768
      v.cpus = 1
    end
  end

  # Define VM for nginx server 2 in net-dmz
  config.vm.define "nginx-2" do |nginx2|
    nginx2.vm.box = "bento/oracle-9.0"
    nginx2.vm.hostname = "nginx-2"
    # Configure private network with DHCP for net-dmz
    nginx2.vm.network "private_network", type: "dhcp", mac: "080027123469", virtualbox__intnet: "net-dmz"
    nginx2.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end
end
