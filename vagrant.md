# 利用vagrant结合KVM管理虚拟机

**系统环境**

OS: ubuntu 18.04

系统支持虚拟化

## 安装KVM

```bash
apt install qemu qemu-kvm libvirt-bin bridge-utils virt-manager libvirt-dev
service libvirtd start
update-rc.d libvirtd enable
#检查服务状态
service libvirtd status
```



## 安装Vagrant

```bas
wget https://releases.hashicorp.com/vagrant/2.2.5/vagrant_2.2.5_x86_64.deb
dpkg -i vagrant_2.2.5_x86_64.deb
# 创建软连接以便使用方便
ln -s /usr/bin/vagrant  /usr/bin/v
# 安装插件用于支持libvirt
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate
vagrant plugin install vagrant-rekey-ssh
```

## 准备好配置文件

```bash
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
 (1..3).each do |i|
   config.vm.define "lab#{i}" do |node|
    node.vm.box = "generic/ubuntu1804"
    node.ssh.insert_key = "false"  
    node.vm.hostname = "lab#{i}"
    node.vm.network "private_network", ip: "11.11.11.11#{i}"
    node.vm.provision "shell", run: "always",
      inline: "echo hello from lab#{i}"
    node.vm.provider "virtualbox" do |v|
      v.cpus = 2
      v.customize ["modifyvm", :id, "--name", "lab#{i}", "--memory", "2048"]
    end
   end
 end
end
```

## 启动安装程序

```bash
vagrant up
```

## 配置root账户登录

```bash
#修改虚拟机的root账户密码--vagrant
sudo passwd root
#修改sshd服务配置
sudo vi /etc/ssh/sshd_config
#清除以下几项的注释
PubkeyAuthentication yes
PasswordAuthentication yes
#重启sshd服务
sudo systemctl restart sshd
#复制主机的公钥至虚拟机的.ssh目录的authorized_keys文件上
vi .ssh/authorized_keys
```

## 修改Vagrantfile配置文件

```bash
node.ssh.insert_key = "true" 
node.ssh.username = "root" 
node.ssh.password = "vagrant"
```

## 重启虚拟机

```bash
vagrant halt
vagrant up
```



