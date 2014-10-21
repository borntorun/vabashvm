# vabashvm

Create and provision vm's for VirtualBox using Vagrant using shell scripts.

The script permits the creation of VirtualBox vm from the Vagrant box specified and according to the parameters used
The aim for this project is to facilitate the rapid creation of a vm with a certain group of packages installed (selected by the user) permiting the correct configuration of the vm for the intended work. 

<hr>
### Requirements

You will need the following software installed in your system:

  - [Vagrant](http://www.vagrantup.com/)
  - [VirtualBox](https://www.virtualbox.org/)
  
### Systems and Shell versions tested: 

* Windows 7
	- GNU bash, version 3.1.20(4)-release-(i686-pc-msys) a.k.a. Git Bash

### How to use

- Clone the project
- Update $PATH with project folder
- $ vabashvm.sh -b<box_name>

or, to see usage parameters 

- $ vabashvm.sh -h

### Description

Permits:

- optional use of [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) plugin
- provision the machine with any script provided in the [packages file](https://github.com/borntorun/vabashvm/blob/master/provision/packages) 
- arguments to be passed to provision scripts