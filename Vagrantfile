NUM_WORKER_NODES=3
IP_NW="172.16.94."
IP_START=10

Vagrant.configure("2") do |config|
  config.vm.provision "shell", env: {"IP_NW" => IP_NW, "IP_START" => IP_START, "NUM_WORKER_NODES" => NUM_WORKER_NODES}, inline: <<-SHELL
      apt-get update -y
      echo "$IP_NW$((IP_START)) c1-cp1" >> /etc/hosts
      for (( i=1; i<=$NUM_WORKER_NODES; i++ ))
      do
        echo "$IP_NW$((IP_START+i)) c1-node$1" >> /etc/hosts
      done
  SHELL

  config.vm.box = "ubuntu/jammy64"
  config.vm.box_check_update = true

  config.vm.define "master" do |master|
    master.vm.hostname = "cp-cp1"
    master.vm.network "private_network", ip: IP_NW + "#{IP_START}"
    master.vm.provider "virtualbox" do |vb|
        vb.memory = 4048
        vb.cpus = 2
    end
    master.vm.provision "shell", path: "scripts/common.sh"
    master.vm.provision "shell", env: {"MASTER_IP" => IP_NW + "#{IP_START}"},  path: "scripts/master.sh"
  end

  (1..NUM_WORKER_NODES).each do |i|

  config.vm.define "node0#{i}" do |node|
    node.vm.hostname = "cp1-node#{i}"
    node.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"
    node.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 1
    end
    node.vm.provision "shell", path: "scripts/common.sh"
    node.vm.provision "shell", path: "scripts/node.sh"
  end

  end
end 
