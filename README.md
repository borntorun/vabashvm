# vabashvm

Create and provision vm's for VirtualBox using Vagrant using shell scripts.

The script permits the creation of VirtualBox vm from the Vagrant box specified and according to the parameters used
The aim for this project is to facilitate the rapid creation of a vm with a certain group of packages installed (selected by the user) permiting the correct configuration of the vm for the intended work. 

<hr>
### Requirements

You will need the following software installed in your system:

  - [Vagrant](http://www.vagrantup.com/)
  - [VirtualBox](https://www.virtualbox.org/)
  - a shell environment...
  
### Description

Permits:

- optional use of [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) plugin
- provision the machine with any script provided in the [packages file](https://github.com/borntorun/vabashvm/blob/master/provision/packages) 
- arguments to be passed to provision scripts
	
### How to use

- Clone the project
- Update $PATH with project folder
- $ vabashvm.sh -b\<box_name>

or, to see usage parameters 

- $ vabashvm.sh -h

### Vagrant Box used and tested: 

- From this github project [Centos7-devel-x86_64](https://github.com/borntorun/packer-vagrant-centos)
- others to come...

### Systems/Environments versions tested: 

* Windows 7
	- MSYS (Minimal SYStem) provided by MinGW / GNU bash, version 3.1.20(4)-release-(i686-pc-msys)

### Shell scripts for provision packages included

- [Packages List](https://github.com/borntorun/vabashvm/blob/master/provision/list-of-packages)

### Comments, Contributions and Testing

- are much welcome and appreciatted...

### Author

	João Carvalho, 2014