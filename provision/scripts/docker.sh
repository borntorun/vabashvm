#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install docker engine, docker compose and docker machine
##
## $1 - username to determine the user to add to docker group
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="docker"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

which docker >/dev/null 2>&1
[[ $? -eq 0 ]] && output "Docker is already installed. Nothing to do." && exit 0

## verify if there is a specifiv user to add to docker group
: ${vabashvm_user=$1}

output "Preparing to install..."

## Get and install docker

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
output "Installing docker engine..."
sudo yum -y install docker-engine >/dev/null 2>&1
[[ ! $? -eq 0 ]] && output "Not installed." && exit 0
output "Configuring..."
[[ -n $vabashvm_user ]] && sudo usermod -aG docker "$vabashvm_user"
sudo systemctl start docker.service >/dev/null 2>&1 && sudo docker info >/dev/null 2>&1 && sudo docker version && sudo systemctl enable docker.service >/dev/null 2>&1
curl -XGET -O https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker >/dev/null 2>&1
sudo mv docker /etc/bash_completion.d/docker

output "Docker engine Installed."

output "Installing docker-compose..."
curl -L -O https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m`  >/dev/null 2>&1
sudo mv docker-compose-`uname -s`-`uname -m` /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
output "Configuring..."
curl -XGET -O https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose >/dev/null 2>&1
sudo mv docker-compose /etc/bash_completion.d/docker-compose

output "Docker compose Installed."

output "Installing docker-machine..."
curl -L -O https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-`uname -s`-`uname -m` >/dev/null 2>&1
sudo mv docker-machine-`uname -s`-`uname -m` /usr/local/bin/docker-machine
sudo chmod +x /usr/local/bin/docker-machine
output "Configuring..."

curl -XGET -O https://raw.githubusercontent.com/docker/machine/master/contrib/completion/bash/docker-machine.bash >/dev/null 2>&1
sudo mv docker-machine.bash /etc/bash_completion.d/docker-machine.bash

curl -XGET -O https://raw.githubusercontent.com/docker/machine/master/contrib/completion/bash/docker-machine-wrapper.bash >/dev/null 2>&1
sudo mv docker-machine-wrapper.bash /etc/bash_completion.d/docker-machine-wrapper.bash

#to future use? see instructions on the script
#curl -XGET -O https://raw.githubusercontent.com/docker/machine/master/contrib/completion/bash/docker-machine-prompt.bash >/dev/null 2>&1
#sudo mv docker-machine-prompt.bash /etc/bash_completion.d/docker-machine-prompt.bash

output "Docker machine Installed."

rm -f z_vabashvm_$_thispackage.sh


printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
