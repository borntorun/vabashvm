# vabashvm

Create and provision vm's for VirtualBox using Vagrant using shell scripts.

<hr>
### Description

The script permits the creation of VirtualBox vm from the Vagrant box specified and according to the parameters used.
The aim for this project is to facilitate the rapid creation of a vm with a certain group of packages installed (selected by the user).
This is intended only for development/testing environments.

Permits:

    - optional use of [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) plugin
    - provision the machine with any script provided in the [packages file](https://github.com/borntorun/vabashvm/blob/master/provision/packages) 
    - arguments to be passed to provision scripts

### Requirements

You will need the following software installed in your system:

  - [Vagrant](http://www.vagrantup.com/)
  - [VirtualBox](https://www.virtualbox.org/)
  - a shell environment...
  - a supported [Vagrant Box](#vboxsupported)  
    

	
### How to use

- Clone the project
- (optional:Update $PATH with project folder)
- $ vabashvm.sh -b\<box_name> -m\<vm_name>
    - the script will create a folder 'machines/\<vm_name> in current folder to hold the vagrant files
- access the folder created and use vagrant commands as usual

or, to see usage parameters 

- $ vabashvm.sh -h

### <a name="vboxsupported"/>Vagrant Box supported, used and tested (until now): 

- CentOS 7 - From this github project [Centos7-devel-x86_64](https://github.com/borntorun/packer-vagrant-centos)
    
- others to come...

### Systems/Environments versions tested: 

* Windows 7
	- Packer v0.7.1
	- VirtualBox 4.3.12 r.93733 with 4.3.14 guest additions (see [here](https://forums.virtualbox.org/viewtopic.php?f=3&t=62485&start=15#p298960) why)
    - VirtualBox 4.3.16 r.95972 with 4.3.16 guest additions 
	- Vagrant 1.6.5
	- vagrant-vbguest plugin (0.10.0)
	- MSYS (Minimal SYStem) provided by MinGW / GNU bash, version 3.1.20(4)-release-(i686-pc-msys)

### Shell scripts for provision packages included

- [Packages List](https://github.com/borntorun/vabashvm/blob/master/provision/list-of-packages)

### Comments, Contributions and Testing...

- are much welcome and appreciatted...

### Author

	João Carvalho, 2014
